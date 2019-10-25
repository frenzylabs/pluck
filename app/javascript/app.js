import React              from 'react'
import {
  withRouter
} from 'react-router-dom'
import { 
  Header, 
  Divider, 
  Grid, 
  Image, 
  Label, 
  Container, 
  Menu,
  Item,
  Button,
  Input,
  Card,
  Advertisement
} from 'semantic-ui-react'

import Headline from './components/headline'
import Results  from './components/results'
import Footer   from './components/footer'

import logo from 'images/pluck-logo.svg'

import {
  ImageSearch,
  TextSearch
 } from './components/search'

const qs = require('qs');

export class App extends React.Component {
  constructor(props) {
    super(props)

    var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })

    this.state = {        
        kind: 'text', // or image
        search: {
          page:     parseInt(qparams["page"] || 1), 
          per_page: parseInt(qparams["per_page"] || 20), 
          q:        qparams["q"] || ""
        },
        searchTerm: qparams["q"] || "",
        results: [],
      }
      // this.state = {
      //   results: [],
      //   kind: 'text',
      //   search: {"page": 1}
      // }

    this.updateResults = this.updateResults.bind(this)
    this.updateImageResults  = this.updateImageResults.bind(this)
    this.searchTerm     = this.searchTerm.bind(this)
    this.onPageChange   = this.onPageChange.bind(this)
  }

  componentDidMount() {
    this.loadThings()
  }
  
  componentDidUpdate(prevProps, prevState) {
    if (this.props.location.path != prevProps.location.path || this.props.location.search != prevProps.location.search) {
      gtag('config', 'UA-144217456-2', {
         'page_location': document.location.href,
       });
    }
    if (this.props.location.search != prevProps.location.search) {
      var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })
      
      var search = {
        page:     parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q:        qparams["q"] || ''
      }

      this.setState({search: search})
      return
    }
    
    if (this.state.kind == "text" && JSON.stringify(this.state.search) != JSON.stringify(prevState.search)) {
      var url = qs.stringify(this.state.search, { addQueryPrefix: true })
    
      this.props.history.push(`${url}`)

      this.loadThings()
    }
    else if (this.state.kind == "image" && JSON.stringify(this.state.search) != JSON.stringify(prevState.search)) {
      var url = qs.stringify(this.state.search, { addQueryPrefix: true })
    
      this.props.history.push(`${url}`)
    }  
  }

  loadThings() {
    var query = qs.stringify(this.state.search, { addQueryPrefix: true })    
    fetch('/api/v1/things.json'+ query)
      .then((response) => { return response.json()})
      .then((data) => {
        var search = this.state.search

        if (this.state.search.per_page != data.meta.per_page) {
          search.per_page = data.meta.per_page

          var url = qs.stringify(search, { addQueryPrefix: true })

          this.props.history.push(`${url}`)
        }

        this.updateResults(data.data, search) 
      });
  }

  updateResults(results, search) {
    this.setState({
      results: results,
      search: search
    })
  }

  updateImageResults(data, page) {
    this.setState({
      kind: 'image',
      search: {
        ...this.state.search,
        page: 1,
        q:    ""
      },
      results: data
    })

    // this.updateResults(data, "image", this.state.search)
  }

  searchTerm(term) {
    this.setState({
      kind: 'text',
      search: {
        ...this.state.search,
        page: 1,
        q:    term
      }
    })
  }

  onPageChange(e, data) {
    if (this.state.search.page < data.activePage) {
      window.scrollTo(0, 0)
    }
    this.setState({search: {...this.state.search, page: data.activePage}})
  }

  renderMenu() {
    return (
      <Menu vertical size='large'>
        <Menu.Item>
          <Header as='h2'>
            <Image size="tiny" src={logo}/> Pluck
          </Header>
        </Menu.Item>

        <Menu.Item>
          <TextSearch searchTerm={this.searchTerm} search={this.state.search} />
        </Menu.Item>

        <Menu.Item>
          <ImageSearch updateImageResults={this.updateImageResults} activeSrc={this.state.kind} page={1}/>
        </Menu.Item>
      </Menu>
    )
  }

//   <Menu.Item>
//   <Advertisement unit='small square' style={{border: '1px solid #c0c0c0'}}>
//     <h4>AdverTitle</h4>
//     <p>This is something something something</p>
//   </Advertisement>
// </Menu.Item>

  render() {
    return (
      <Container fluid id="master-detail">
        <Grid stretched columns='equal' className="main-content">
            <Grid.Column width={3} id="left-menu" >
              {this.renderMenu()}
            </Grid.Column>

            <Grid.Column id="master-content">
              <h1 className="title" style={{textAlign: 'center'}}>Search for 3D Models</h1>


              <Container fluid style={{overflowX: 'auto', overflowY: 'auto', height:'100%', minHeight: '100%'}}>
                <div style={{padding: '40px 0'}}>
                  <Results {...this.props} items={this.state.results} kind={this.state.kind} search={this.state.search} onPageChange={this.onPageChange} />
                </div>
              </Container>
            </Grid.Column>
        </Grid>
      </Container>
    )
  }
}

export default withRouter(App)
