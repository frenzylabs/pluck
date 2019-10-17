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

    this.state = {
      term: ""
    }

    this.submitAction = this.submitAction.bind(this)
    this.changeAction = this.changeAction.bind(this)
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
          <Input icon='search' placeholder='Search for model...' size='small' onChange={this.changeAction} />
        </Form>
      </React.Fragment>
    )
  }
}
