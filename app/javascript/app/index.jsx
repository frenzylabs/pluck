//
//  index.js
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/22/20
//  Copyright 2020 FrenzyLabs LLC.
//

import React        from 'react'
import {withRouter} from 'react-router-dom'

import qs from 'qs'

import {
  Nav,
  Results,
  Pagination
} from './components'

class App extends React.Component {
  constructor(props) {
    super(props)

    const {page, per_page, q} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})

    this.state = {
      loading: false,
      kind: 'text',
      search: {
        page:     parseInt(page) || 1,
        per_page: parseInt(per_page) || 21,
        q:        q
      },
      searchTerm: q || "",
      results:    []
    }

    this.load         = this.load.bind(this)
    this.update       = this.update.bind(this)
    this.search       = this.search.bind(this)
    this.onPageChange = this.onPageChange.bind(this)
  }

  load() {
    this.setState({loading: true})

    const endpoint = 
      '/api/v1/things.json' +
      qs.stringify(this.state.search, { addQueryPrefix: true })

    fetch(endpoint)
    .then(res => res.json())
    .then(data => {
      var search = this.state.search

      if(this.state.search.per_page != data.meta.per_page) {
        search.per_page = data.meta.per_page

        this.props.history.push(
          qs.stringify(search, { addQueryPrefix: true })
        )
      }

      this.update(data.data, search)
    })
    .finally(() => this.setState({loading: false}))
  }

  update(data, search) {
    this.setState({
      results:  data,
      search:   search
    })
  }

  search(term) {
    this.setState({
      kind: 'text',
      search: {
        ...this.state.search,
        page: 1,
        q: term
      }
    })
  }

  onPageChange(e, data) {
    this.setState({
      search: {
        ...this.state.search,
        page: data.activePage
      }
    })
  }
  
  componentDidMount() {
    this.load()
  }

  componentDidUpdate(prevProps, prevState) {
    if(this.props.location.search != prevProps.location.search) { 
      const {page, per_page, q} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})
      
      this.setState({
        search: {
          page:     page,
          per_page: per_page,
          q:        q || ""
        }
      })

      return
    }

    if(JSON.stringify(this.state.search) != JSON.stringify(prevState.search)) {
      this.props.history.push(
        qs.stringify(this.state.search, { addQueryPrefix: true })
      )

      this.load()
    }
  }

  renderPagination() {
    const {page, per_page} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})

    var activePage  = page || 1
    var perPage     = per_page || 20
    var totalPages  = activePage

    if (this.state.results.length >= perPage) {
      totalPages = activePage + 1
    }

    return (
      <Pagination
        activePage={activePage}
        totalPages={totalPages}
        onPageChange={this.onPageChange}
      />
    )
  }

  render() {
    return (
      <div style={{paddingBottom: '300px'}}>
        <Nav disabled={this.state.loading} handleSearch={this.search}/>

        <Results
          {...this.props}

          items={this.state.results}
          search={this.state.search}
        />

        {this.renderPagination()}

        <br/><br/>

      </div>
    )
  }
}

export default withRouter(App)
