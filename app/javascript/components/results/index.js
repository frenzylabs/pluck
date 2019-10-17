//
//  index.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/15/19
//  Copyright 2019 Wess Cope
//

import React from 'react'

import { 
  Container, 
  Grid, 
  Card,
  Pagination
} from 'semantic-ui-react'

import Result from './result'

export default class Results extends React.Component {
  constructor(props) {
    super(props)

    this.renderItems = this.renderItems.bind(this)
  }

  renderItems() {
    return (this.props.items || []).map((item, index) => {
      return (
        <Result key={index}/>        
      )
    })
  }

  render() {
    return (
      <Container fluid id="results">
        <Container style={{paddingBottom: '100px'}}>
          <br/><br/>

          <Card.Group centered>
            {this.renderItems()}
          </Card.Group>

          <Card.Group centered>
            <Pagination
              boundaryRange={0}
              defaultActivePage={1}
              ellipsisItem={null}
              firstItem={null}
              lastItem={null}
              siblingRange={1}
              totalPages={10}
            />
          </Card.Group>

          <br/><br/>
        </Container>
      </Container>
    )
  }
}
