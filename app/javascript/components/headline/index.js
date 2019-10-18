//
//  index.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/15/19
//  Copyright 2019 Wess Cope
//

import React from 'react'

import { 
  Menu, 
  Container,
  Image,
  Grid,
  Form,
  Card,
  Input,
  Button,
  Divider,
  Header,
  Segment
} from 'semantic-ui-react'

import logo from 'images/pluck-logo.svg'

export default class Headline extends React.Component {

  constructor(props) {
    super(props)
  }

  render() {
    return (
      <Container fluid className="mobile tablet only">
        <Card fluid>
          <Card.Content>
            <Grid stretched columns='equal'>
              <Grid.Column width={2}>
                <Image size="mini" src={logo} />
              </Grid.Column>

              <Grid.Column>
                <Input icon='search' placeholder='Search...' style={{width: '100%'}} />
              </Grid.Column>
            </Grid>
          </Card.Content>

          <Card.Content>
            <Grid stretched columns='equal'>
              <Grid.Column>
                <p>Or select an image to find similiar models</p>
              </Grid.Column>

              <Grid.Column>
                <Button primary>Select</Button>
              </Grid.Column>
            </Grid>
          </Card.Content>

        </Card>
      </Container>
    )
  }
}
