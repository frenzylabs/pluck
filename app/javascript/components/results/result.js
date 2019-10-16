//
//  result.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/15/19
//  Copyright 2019 Wess Cope
//

import React from 'react'

import { 
  Card, 
  Button,
  Image
} from 'semantic-ui-react'

export default class Result extends React.Component {
  render() {
    return (
      <Card>
        <Image src='https://cdn.thingiverse.com/renders/1f/4a/34/a8/29/3a0ad421fde6574a2f0c16445e944d0e_thumb_large.jpg' wrapped ui={false}/>
        <Card.Content>
          <Card.Description>
            Description
          </Card.Description>
        </Card.Content>
        <Card.Content extra>
          <Button.Group fluid>
            <Button basic size='small' color='grey' attached='left' compact>Thingiverse</Button>
            <Button basic size='small' color='blue' attached='right' compact>LayerKeep</Button>
          </Button.Group>
        </Card.Content>
      </Card>
    )
  }
}
