//
//  index.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/16/19
//  Copyright 2019 Wess Cope
//

import React from 'react'

import { 
  Menu,
  Header,
  Button,
  Image,
  Input,
  Card,
  Advertisement
} from 'semantic-ui-react'

import {
  ImageSearch,
  TextSearch
 } from '../search'

const qs = require('qs');

export default class Master extends React.Component {
  constructor(props) {
    super(props)

    var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })

    this.state = {
      search: {
        page:     parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q:        qparams["q"] || ""
      },
      searchTerm: qparams["q"] || ""
    }

    this.updateResults  = this.updateResults.bind(this)
    this.searchTerm     = this.searchTerm.bind(this)
  }

  componentDidUpdate(prevProps, prevState) {
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
    
    if (JSON.stringify(this.state.search) != JSON.stringify(prevState.search)) {
      var url = qs.stringify(this.state.search, { addQueryPrefix: true })
    
      this.props.history.push(`${url}`)

      this.loadThings()
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
    if(this.props.updateResults) {
      this.props.updateResults(results, search)
    }
  }

  updateImageResults(data, page) {
    this.state.search.page = page

    this.updateResults(data, search)
  }

  searchTerm(term) {
    this.setState({
      search: {
        ...this.state.search,
        page: 1,
        q:    term
      }
    })
  }

  render() {
    return (
      <Menu vertical size='large'>
        <Menu.Item>
          <Header as='h2'>
            <Image size="tiny" src="/assets/pluck-logo.svg"/> Pluck
          </Header>
        </Menu.Item>

        <Menu.Item>
          <TextSearch searchTerm={this.searchTerm} />
        </Menu.Item>

        <Menu.Item>
          <ImageSearch updateImageResults={this.updateImageResults} page={1}/>
        </Menu.Item>

        <Menu.Item>
          <Advertisement unit='small square' style={{border: '1px solid #c0c0c0'}}>
            <h4>AdverTitle</h4>
            <p>This is something something something</p>
          </Advertisement>
        </Menu.Item>
      </Menu>
    )
  }
}
