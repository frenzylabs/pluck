//
//  index.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/17/19
//  Copyright 2019 Wess Cope
//

import React    from 'react'
import * as tf  from '@tensorflow/tfjs'

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


export default class ImageSearch extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      model_version:  0,
      disabled:       true,
      loading:        false,
      imageSrc:       "/assets/image-placeholder.png"
    }

    window.t  = this
    window.tf = tf;

    this.loadLatestModel    = this.loadLatestModel.bind(this)
    this.loadModel          = this.loadModel.bind(this)
    this.searchImage        = this.searchImage.bind(this)
    this.loadSearchResults  = this.loadSearchResults.bind(this)
    this.enableAction       = this.enableAction.bind(this)
    this.renderDisabled     = this.renderDisabled.bind(this)
    this.renderLoading      = this.renderLoading.bind(this)
    this.renderSelect       = this.renderSelect.bind(this)
    this.handleDrop         = this.handleDrop.bind(this)
    this.onFileChange       = this.onFileChange.bind(this)
    this.renderNothing      = this.renderNothing.bind(this)
  }

  componentDidMount() {
    this.loadLatestModel()
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

  async loadModel() {
    if(this.state.model_version < 1) { return }

    this.setState({
      loading: true,
      disabled: false
    })

    this.model = new Promise((resolve, reject) => {
      var amodel = tf.loadLayersModel(`indexeddb://pluck-models-${this.state.model_version}`);

      amodel.then((data) => {
        resolve(data)
      }).catch((error) => {
        console.log(error)

        var bmodel = tf.loadLayersModel(`/api/v1/model_versions/${this.state.model_version}/model.json`)

        bmodel.then((data) => {
          data.save(`indexeddb://pluck-models-${this.state.model_version}`);
        })

        return resolve(bmodel)
      })

      return amodel
    }).finally(() => {
      this.setState({
        loading: false
      })
    })
  }

  async searchImage(img) {
    const raw           = tf.browser.fromPixels(img)
    const resized       = tf.image.resizeBilinear(raw, [224, 224])
    const expanded      = resized.expandDims(0)
    const prediction    = await this.model.then(model => model.predict(expanded))
    const similarities  = await prediction.array()

    this.indices = similarities[0]
      .map((val, index) => {return {index, val}})
      .sort((a, b) => {return a.val < b.val ? 1 : -1 })
      .map(o => o.index)

    this.state.search.page = 1

    var url = qs.stringify(this.state.search, { addQueryPrefix: true });

    this.props.history.push(`${url}`);
    this.loadSearchResults()

    raw.dispose()
    resized.dispose()
    expanded.dispose()
    prediction.dispose()
  }

  loadSearchResults() {
    const page  = this.props.page || 1
    const url   = "/api/v1/model_versions/1/things.json"
    var data    = this.indices.slice((page - 1) * 100, 100)
.
    fetch(url, {
      method: 'POST',
      credentials: 'same-origin',
      headers: {
        'Content-Type': 'application/json'
      },
      redirect: 'follow',
      referrer: 'no-referrer',
      body: JSON.stringify({indices: data})
    })
    .then((response) => { return response.json()})
    .then((data) => {
      if(this.props.updateImageResults) {
        this.props.updateImageResults(data.data, page)
      }
    })
  }

  enableAction(e) {
    if(this.state.disabled || this.state.model_version == 0) { return; }

    this.loadModel()
  }

  renderImage(url) {
    var lurl = url.replace(/(thumb_)(medium)(\.)/, '$1large$3');
    return (<Image src={`${lurl}`} onError={(ev) => ev.target.src = url } />)    
  }

  handleDrop(files, evt) {
    this.handleFileChange(files[0])
  }

  handleFileChange(file) {
    var reader = new FileReader()

    reader.onload = async (file_load_event) => {
      this.setState({imageSrc: file_load_event.target.result})
    
      var readInImage = document.createElement("img")
    
      readInImage.onload = () => {
        this.searchImage(readInImage)
      }
    
      readInImage.src = file_load_event.target.result  
    }

    reader.readAsDataURL(file)
  }


  onFileChange(evt) {
    if (evt.target.files.length > 0) {
      var file = evt.target.files[0]
  
      this.handleFileChange(file)
    }

    evt.target.value = ""
  }

  renderDisabled() {
    return(
      <Card>
        <Card.Content textAlign='center' style={{background: '#eaeaea'}}>
          <br/><br/>
          <Icon name='lab' size='huge'/>
          <br/><br/>
        </Card.Content>

        <Card.Content>
          <Card.Description>
              Smart object matching is currently in
              an experimental state. If enabled we will
              be loading a lot of data into your browser.
          </Card.Description>
        </Card.Content>

        <Card.Content extra>
          <Button fluid color='yellow' onClick={this.loadModel}>Enable</Button>
        </Card.Content>
      </Card>
    )
  }

  renderLoading() {
    return (
      <Dimmer active inverted>
        <Loader indeterminate>
          This may take a while...
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
    return this.state.model_version > 0 ? (this.state.disabled ? this.renderDisabled() : this.renderSelect()) : this.renderNothing()
  }
}
