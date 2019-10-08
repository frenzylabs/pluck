import React              from 'react'
import { Link }         from 'react-router-dom';

const qs = require('qs');
import * as tf from '@tensorflow/tfjs';

import { Form, Input, Button, Menu, Grid, Image, Label } from 'semantic-ui-react'
import { Pagination } from 'semantic-ui-react'

export default class Things extends React.Component {
  constructor(props) {
    super(props);

    var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })

    this.state = {
      things: [],
      search: {
        page: parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q: qparams["q"] || ""
      },
      searchTerm: qparams["q"] || ""
    };

    this.loadThings   = this.loadThings.bind(this)
    this.searchChange = this.searchChange.bind(this)
    this.searchThings = this.searchThings.bind(this)
    this.onPageChange = this.onPageChange.bind(this)
    window.t = this
    window.tf = tf;
    
  }

  componentDidMount(){
    this.loadThings()
    this.model = tf.loadLayersModel('http://localhost:3001/models/model.json')
    console.log(this.model);
    // .then((val) => {
    //   console.log("MODEL LOADED =", val)
    //   // this.model = val

    // })
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
    evt.persist()
    console.log(evt.target);
    window.evt = evt;
    // var files = evt.dataTransfer.files // Array of all files
    var file = evt.target.files[0]
    
    var reader = new FileReader()
    // reader.onload = async function(file_load_event) {
    //   var readInImage = document.createElement("img")
    //   readInImage.onload = function() {
    //     visualSearch.search(readInImage)
    //         visualSearch.resizeAndDisplayImage(el, readInImage)
    //       }
    //       readInImage.src = file_load_event.target.result
    //   }
      reader.onload = async (file_load_event) => {
        var readInImage = document.createElement("img")
        readInImage.onload = () => {
          this.searchImage(readInImage)
          // visualSearch.resize4AndDisplayImage(el, readInImage)
        }
        readInImage.src = file_load_event.target.result
      }
      reader.readAsDataURL(file)
  }

  async searchImage(img) {
    console.log("searchImage");
    const raw = tf.browser.fromPixels(img)
    const resized = tf.image.resizeBilinear(raw, [224, 224])
    const expanded = resized.expandDims(0)
    const prediction = await this.model.then(model => model.predict(expanded))
    const similarities = await prediction.array()

    const indices = similarities[0]
      .map((val, index) => {return {index, val}})
      .sort((a, b) => {return a.val < b.val ? 1 : -1 })
      .slice(0, 10)
      .map(o => o.index)

    console.log(indices);
    // this.loadSearchResults(indices)

    raw.dispose()
    resized.dispose()
    expanded.dispose()
    prediction.dispose()
  }

  async fileLoaded(file_load_event) {
    var readInImage = document.createElement("img")
    readInImage.onload = () => {
      this.search(readInImage)
      visualSearch.resize4AndDisplayImage(el, readInImage)
    }
    readInImage.src = file_load_event.target.result

  }
  renderImage(url) {
    var lurl = url.replace(/(thumb_)(medium)(\.)/, '$1large$3');
    return (<Image src={`${lurl}`} onError={(ev) => ev.target.src = url } />)    
  }

  render(){
    var things = this.state.things.map((thing) => {
      return (
        <Grid.Column key={thing.id} className={"thing"}>
            <div className={"thing-top"}>
              {this.renderImage(thing.image_url)}              
              <Label>{thing.name}</Label>
            </div>
            <Menu>
              <Menu.Item link={true} as={"a"} target="_blank" href={`http://thingiverse.com/thing:${thing.thingiverse_id}`}>
                <span>Visit</span>
              </Menu.Item>

              <a className={"link"} target="_blank" href={`https://layerkeep.dev/projects/new?source=thingiverse&thing_id=${thing.thingiverse_id}`}>
                <span>Manage On Layerkeep</span>
              </a>
            </Menu>
            
        </Grid.Column>
      )
    })

    var totalPages = this.state.search.page
    if (things.length >= this.state.search.per_page) {
      totalPages = this.state.search.page + 1
    }

    return (
      <div className={"column container ui"}>
        <div className={"container"} style={{"margin": "20px"}}>
          <div><input type="file" name="img" id="imgfile" onChange={(evt) => this.onFileChange(evt) } /></div>
          <Form onSubmit={this.searchThings}>
            <Form.Field >
              <Input action={{ icon: 'search' }} onChange={this.searchChange} placeholder='Search...' value={this.state.searchTerm} />
            </Form.Field>
          </Form>
        </div>
        <div className={"container"}>
          <Grid doubling columns={5}>
            {things}
          </Grid>
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
