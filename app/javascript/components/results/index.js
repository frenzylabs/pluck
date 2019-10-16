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

    var items = []
    for(var i = 0; i < 20; i++) {
      items.push(i)
    }

    return items.map((item, index) => {
      return (
        <Result key={index}/>        
      )
    })
  }

  render() {
    return (
      <Container id="results">
        <Grid>
          <Grid.Column width={14}>
            <Card.Group itemsPerRow={4}>
              {this.renderItems()}
            </Card.Group>

            <br/>
            <br/>
                        
            <Grid centered>
              <Grid.Column width={4}>
                <Pagination
                  boundaryRange={0}
                  defaultActivePage={1}
                  ellipsisItem={null}
                  firstItem={null}
                  lastItem={null}
                  siblingRange={1}
                  totalPages={10}
                />
              </Grid.Column>
            </Grid>
          </Grid.Column>

          <Grid.Column>
            right
          </Grid.Column>
        </Grid>
      </Container>
    )
  }
}
