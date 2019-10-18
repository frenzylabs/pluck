//
//  text.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/17/19
//  Copyright 2019 Wess Cope
//

import React from 'react'

import {
  Form,
  Input
} from 'semantic-ui-react'

export default class TextSearch extends React.Component {
  constructor(props) {
    super(props)

    var term = ""
    if (props.search && props.search.q) {
      term = props.search.q || ""
    }
    this.state = {
      term: term
    }

    this.submitAction = this.submitAction.bind(this)
    this.changeAction = this.changeAction.bind(this)
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.search && this.props.search.q != prevProps.search.q) {
      this.setState({term: this.props.search.q})
    }
  }

  changeAction(e, data) {
    this.setState({
      term: data.value
    })
  }

  submitAction(e) {
    e.preventDefault()

    const page = this.props.page || 1

    if(this.props.searchTerm) {
      this.props.searchTerm(this.state.term)
    }
  }

  render() {
    return (
      <React.Fragment>
        <Form onSubmit={this.submitAction}>
          <Input fluid icon='search' placeholder='Search for model...' onChange={this.changeAction} value={this.state.term} />
        </Form>
      </React.Fragment>
    )
  }
}
