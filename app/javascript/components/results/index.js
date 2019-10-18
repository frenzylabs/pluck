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
        <Result key={index} image={item.attributes.image_url} name={item.attributes.name} tid={item.attributes.thingiverse_id}/>        
      )
    })
  }


  renderPagination() {
    if (this.props.kind == "text") {
      var activePage = this.props.search.page || 1
      var perPage = this.props.search.per_page || 20
      var totalPages = activePage
      if (this.props.items.length >= perPage) {
        totalPages = activePage + 1
      }
      return (
        <Pagination
          boundaryRange={0}
          defaultActivePage={activePage}
          ellipsisItem={null}
          firstItem={null}
          lastItem={null}
          siblingRange={1}
          totalPages={totalPages}
          onPageChange={this.props.onPageChange}
          style={{"margin": "20px"}}
        />
      )
    }
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
            {this.renderPagination()}
          </Card.Group>

          <br/><br/>
        </Container>
      </Container>
    )
  }
}
