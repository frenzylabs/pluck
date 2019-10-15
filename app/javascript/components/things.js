import React              from 'react'
import { Link }         from 'react-router-dom';

const qs = require('qs');

import * as tf from '@tensorflow/tfjs';

import { Card, Segment, Header, Divider, Icon, Form, Input, Button, Menu, Grid, Image, Label } from 'semantic-ui-react'
import { Pagination } from 'semantic-ui-react'
import { InputFile } from 'semantic-ui-react-input-file'
import FileDrop from 'react-file-drop';
 

export default class Things extends React.Component {
  constructor(props) {
    super(props);

    var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })

    this.state = {
      model_version: 0,
      things: [],
      search: {
        page: parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q: qparams["q"] || ""
      },
      searchTerm: qparams["q"] || ""
    };

    this.loadThings       = this.loadThings.bind(this)
    this.loadLatestModel  = this.loadLatestModel.bind(this)
    this.searchChange     = this.searchChange.bind(this)
    this.searchThings     = this.searchThings.bind(this)
    this.onPageChange     = this.onPageChange.bind(this)

    this.imageInputRef = React.createRef();
    window.t = this
    window.tf = tf;
    
  }

  componentDidMount(){
    tf.io.removeModel(`indexeddb://pluck-model-1`);
    this.loadLatestModel();
    this.loadThings()
    
  }

  loadLatestModel() {
    fetch('/api/v1/model_versions/latest.json')
      .then((response) => { return response.json()})
      .then((data) => {
        if (data.version && data.version > 0) {
          this.setState({model_version: data.version})
          this.loadModel()
        }
      });
  }

  async loadModel() {
    this.model = new Promise((resolve, reject) => {
      var amodel = tf.loadLayersModel(`indexeddb://pluck-model-${this.state.model_version}`);
      amodel.then((data) => {
        resolve(data)
      }).catch((error) => {
        console.log(error)
        var bmodel = tf.loadLayersModel(`/api/v1/model_versions/${this.state.model_version}/model.json`)
        bmodel.then((data) => {
          data.save(`indexeddb://pluck-model-${this.state.model_version}`);
        })
        return resolve(bmodel)
      });
      return amodel
    });
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.location.search != prevProps.location.search) {
      var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })
      var search = {
        page: parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q: qparams["q"] || ''
      }
      this.setState({search: search})
    }
    else if (JSON.stringify(this.state.search) != JSON.stringify(prevState.search)) {
      var url = qs.stringify(this.state.search, { addQueryPrefix: true });      
      this.props.history.push(`${url}`);
      this.loadThings();
    } 
    // else {
    //   console.log(JSON.stringify(this.state.search))
    //   console.log(JSON.stringify(prevState.search))
    // }
  }

  loadThings() {
    var query = qs.stringify(this.state.search, { addQueryPrefix: true })    
    fetch('/api/v1/things.json'+ query)
      .then((response) => { return response.json()})
      .then((data) => {
        var search = this.state.search
        if (this.state.search.per_page != data.meta.per_page) {
          search.per_page = data.meta.per_page
          var url = qs.stringify(search, { addQueryPrefix: true });
          this.props.history.push(`${url}`);
        }
        this.setState({ things: data.data, search: search }) 
      });
  }

  loadSearchResults() {
    const url = "/api/v1/model_versions/1/things.json"
    var data = this.indices.slice((this.state.search.page - 1) * 100, 100)
    fetch(url, {
      method: 'POST', // *GET, POST, PUT, DELETE, etc.
      // mode: 'cors', // no-cors, *cors, same-origin
      // cache: 'no-cache', // *default, no-cache, reload, force-cache, only-if-cached
      credentials: 'same-origin', // include, *same-origin, omit
      headers: {
        'Content-Type': 'application/json'
      },
      redirect: 'follow', // manual, *follow, error
      referrer: 'no-referrer', // no-referrer, *client
      body: JSON.stringify({indices: this.indices}) // body data type must match "Content-Type" header
    })
    .then((response) => { return response.json()})
    .then((data) => {
      this.setState({ things: data.data}) 
    })
  }

  onPageChange(e, data) {
    this.setState({search: {...this.state.search, page: data.activePage}})
  }
  searchChange(e, data) {
    this.setState({searchTerm: data.value});
  }
  searchThings() {
    this.setState({search: {...this.state.search, page: 1, q: this.state.searchTerm}})
  }

  onFileChange(evt) {
    if (evt.target.files.length > 0) {
      var file = evt.target.files[0]
      this.handleFileChange(file)
    }
    evt.target.value = ""

  }

  async searchImage(img) {
    // console.log("searchImage");
    const raw = tf.browser.fromPixels(img)
    const resized = tf.image.resizeBilinear(raw, [224, 224])
    const expanded = resized.expandDims(0)
    const prediction = await this.model.then(model => model.predict(expanded))
    const similarities = await prediction.array()

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
      this.setState({modelImageSrc: file_load_event.target.result})
      var readInImage = document.createElement("img")
      readInImage.onload = () => {
        this.searchImage(readInImage)
      }
      readInImage.src = file_load_event.target.result
      
    }
    reader.readAsDataURL(file)
  }
  
  renderImageModel() {
    var imgSrc = this.state.modelImageSrc || 'https://react.semantic-ui.com/images/avatar/large/matthew.png'
    var label = (
      <Label
        as='label'
        style={{ cursor: 'pointer' }}
        basic
        content="Select an image to find similar models"
        color="black"
      />
    )
    return (      
      <FileDrop onDrop={this.handleDrop.bind(this)}>
        <Card style={{maxWidth: '224px', margin: '0 auto'}} >
          <Image src={imgSrc} wrapped ui={false} style={{maxWidth: '224px', maxHeight: '224px'}} />
          <Card.Content style={{padding: 0}}>
              <InputFile 
              button={{style: {margin: 0}, label: label, content: (<div>Select Image</div>)}}
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

  renderSearchForm() {
    return (<Segment >
    <Grid columns={2} stackable textAlign='center'>
      <Divider vertical>Or</Divider>

      <Grid.Row verticalAlign='middle'>
        <Grid.Column style={{height: '100%'}}>
          <h1 style={{color: 'black'}}>
            Find Model
          </h1>

          <Form onSubmit={this.searchThings}>
            <Form.Field style={{maxWidth: '100%'}}>
              <Input action={{ icon: 'search' }} onChange={this.searchChange} placeholder='Search...' value={this.state.searchTerm} />
            </Form.Field>
          </Form>
        </Grid.Column>

        <Grid.Column>
          {this.renderImageModel()}
        </Grid.Column>
      </Grid.Row>
    </Grid>
  </Segment>)
  }

  renderThings() {
    var things = this.state.things.map((thing) => {
      return (
        <Grid.Column key={thing.id} className={"thing"}>
            <div className={"thing-top"}>
              {this.renderImage(thing.attributes.image_url)}              
              <Label>{thing.attributes.name}</Label>
            </div>
            <Menu>
              <Menu.Item link={true} as={"a"} target="_blank" href={`${window.currentEnv.domains.thingiverse}/thing:${thing.attributes.thingiverse_id}`}>
                <span>Visit</span>
              </Menu.Item>

              <a className={"link"} target="_blank" href={`${window.currentEnv.domains.layerkeep}/projects/new?source=thingiverse&thing_id=${thing.attributes.thingiverse_id}`}>
                <span>Manage On Layerkeep</span>
              </a>
            </Menu>
            
        </Grid.Column>
      )
    })

    return (<Grid doubling columns={5}>
            {things}
          </Grid>)

  }

  render(){

    var totalPages = this.state.search.page
    if (this.state.things.length >= this.state.search.per_page) {
      totalPages = this.state.search.page + 1
    }

    return (
      <div className={"column container ui"}>
        <div className={"container"} style={{"margin": "20px"}}>
          {this.renderSearchForm()}
        </div>
        <div className={"container"}>
            {this.renderThings()}
        </div>
        <Pagination
          boundaryRange={0}
          defaultActivePage={this.state.search.page}
          ellipsisItem={null}
          firstItem={null}
          lastItem={null}
          siblingRange={1}
          totalPages={totalPages}
          onPageChange={this.onPageChange}
          style={{"margin": "20px"}}
        />
      </div>
    )
  }
}
