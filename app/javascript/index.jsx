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
  TopNav,
  Results,
  PaginatedList
} from './components'

export class App extends React.Component {
  constructor(props) {
    super(props)

    const {page, per_page, q} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})
    console.log("Q = ", q)
    this.state = {
      loading: false,
      kind: 'text',
      search: {
        page:     parseInt(page) || 1,
        per_page: parseInt(per_page) || 20,
        q:        q
      },
      searchTerm: q || "",
      results:    []
    }

    this.load         = this.load.bind(this)
    this.update       = this.update.bind(this)
    this.search       = this.search.bind(this)
    this.onChangePage = this.onChangePage.bind(this)
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
        search.per_page = parseInt(data.meta.per_page)

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
  
  componentDidMount() {
    this.load()
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.state.results != prevState.results) {
      window.scrollTo(0, 0)
    }
    if(this.props.location.search != prevProps.location.search) { 
      const {page, per_page, q} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})
      
      this.setState({
        search: {
          page:     parseInt(page),
          per_page: parseInt(per_page),
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


  onChangePage(page) {
    // update state with new page of items
    this.setState({
      search: {
        ...this.state.search,
        page: parseInt(page)
      }
    })
  }

  renderPagination() {
    const {page, per_page} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})

    var currentPage  = parseInt(page) || 1
    var perPage     = parseInt(per_page) || 20
    var totalPages  = currentPage

    if (this.state.results.length >= perPage) {
      totalPages = currentPage + 1
    }
    var total = this.state.results.length 
    
    if (this.state.results.length > 0) {

      return (
        <PaginatedList location={this.props.location} currentPage={currentPage} pageSize={this.state.search.perPage} totalPages={totalPages} totalItems={total} onChangePage={this.onChangePage} /> 
      )
    }
  }

  renderResults() {
    if (this.state.loading) {
      return (<div className="container"><div className ="spinner is-loading">&nbsp;</div></div>)
    } else {
      return (
        <Results
          {...this.props}
          items={this.state.results}
          search={this.state.search}
        />
      )
    }
  }

  render() {
    return (
      <div style={{paddingBottom: '300px'}}>
        <TopNav disabled={this.state.loading} term={this.state.search.q} handleSearch={this.search} />

        {this.renderResults()}

        {this.renderPagination()}

        <br/><br/>

      </div>
    )
  }
}

export default withRouter(App)
