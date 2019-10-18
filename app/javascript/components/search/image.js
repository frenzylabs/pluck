//
//  index.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/17/19
//  Copyright 2019 Wess Cope
//

import React    from 'react'

const qs = require('qs');


import {
  Image,
  Card,
  Button,
  Icon,
  Dimmer,
  Loader
} from 'semantic-ui-react'

import { InputFile }  from 'semantic-ui-react-input-file'
import FileDrop       from 'react-file-drop'

import placeHolder from 'images/image-placeholder.png'

export default class ImageSearch extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      model_version:  0,
      disabled:       false,
      loading:        false,
      imageSrc:       placeHolder
    }

    this.loadLatestModel    = this.loadLatestModel.bind(this)
    this.renderLoading      = this.renderLoading.bind(this)
    this.renderSelect       = this.renderSelect.bind(this)
    this.handleDrop         = this.handleDrop.bind(this)
    this.onFileChange       = this.onFileChange.bind(this)
    this.renderNothing      = this.renderNothing.bind(this)
    this.handleFileChange   = this.handleFileChange.bind(this)
  }

  componentDidMount() {
    this.loadLatestModel()
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.activeSrc != prevProps.activeSrc && this.props.activeSrc != "image") {
      this.setState({imageSrc: placeHolder})
    }
  }

  loadLatestModel() {
    fetch('/api/v1/model_versions/latest.json')
      .then((response) => { return response.json()})
      .then((data) => {
        if (data.version && data.version > 0) {
          this.setState({
            model_version: data.version
          })
        }
      });
  }

  renderImage(url) {
    var lurl = url.replace(/(thumb_)(medium)(\.)/, '$1large$3');
    return (<Image src={`${lurl}`} onError={(ev) => ev.target.src = url } />)    
  }

  handleDrop(files, evt) {
    this.handleFileChange(files[0])
  }

  handleFileChange(file) {
    this.setState({
      loading: true,
    })
    const formData = new FormData();
    formData.append('image', file, file.name)
    
    if (FileReader && file) {
      var fr = new FileReader();
      fr.onload = async (file_load) => {
        this.setState({imageSrc: fr.result})
      }
      fr.readAsDataURL(file);
    }

    fetch(`/api/v1/model_versions/${this.state.model_version}/image_search`, { // Your POST endpoint
      method: 'POST',
      body: formData 
    }).then(
      response => response.json() // if the response is a JSON object
    ).then((data) => {
      if(this.props.updateImageResults) {
        this.props.updateImageResults(data.data, 1)          
      }
      this.setState({
        loading: false,
      })
      } // Handle the success response object
    ).catch((error) => {
        this.setState({
          loading: false,
        })
        console.log(error)
      }
    );
  }


  onFileChange(evt) {
    if (evt.target.files.length > 0) {
      var file = evt.target.files[0]
      this.handleFileChange(file)
    }

    evt.target.value = ""
  }

  renderLoading() {
    return (
      <Dimmer active inverted>
        <Loader indeterminate>
          Comparing Images...
        </Loader>
      </Dimmer>
    )
  }

  renderSelect() {
    return(
      <FileDrop onDrop={this.handleDrop.bind(this)}>
      <Card>
        {this.state.loading && this.renderLoading() }

          <Image src={this.state.imageSrc}/>

          <Card.Content>
            <Card.Description>
              Select an image to search for similiar models.
            </Card.Description>
          </Card.Content>

          <Card.Content textAlign='center' extra>
            <InputFile
              input={{
                id: 'input-file-id',
                content: "Upload Image",
                onChange: this.onFileChange.bind(this)
              }}
            />
          </Card.Content>
      </Card>
      </FileDrop>
    )
  }

  renderNothing() {
    return (
      <React.Fragment>
        &nbsp;
      </React.Fragment>
    )
  }
  
  render() {
    return this.state.model_version > 0 ? this.renderSelect() : this.renderNothing()
  }
}
