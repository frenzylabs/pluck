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
  Divider
} from 'semantic-ui-react'

export default class Headline extends React.Component {
  render() {
    return (
      <Container fluid id="headline">
        <Menu size='huge' borderless>
          <Container fluid style={{padding: '0 20px'}}>
            <Menu.Item as='a' header>
              <Image size="mini" src="/assets/pluck-logo.svg" avatar />
              <span style={{fontFamily: 'Nexa'}}>&nbsp;Pluck</span>
            </Menu.Item>

            <Menu.Menu position='right'>
              <Menu.Item as='a'>
                About
              </Menu.Item>

              <Menu.Item as='a'>
                Contact
              </Menu.Item>
            </Menu.Menu> 

          </Container>
        </Menu>

        <Container fluid style={{padding: '0 4em 4em 4em'}}>
          <Card fluid id="search-card">
            <Card.Content style={{border: 'none', boxShadow: '0'}}>
              <Grid columns='equal' stretched>                      
                <Grid.Column>
                  <Input
                    fluid
                    size='large' 
                    placeholder='Search for...'
                    icon='search'
                    iconPosition='left'
                    style={{border: 'none'}}
                  />
                </Grid.Column>

                <Grid.Column width={2}>
                  <Button color='green'>
                    Search
                  </Button>
                </Grid.Column>

                <Grid.Column width={1}>
                  <Divider vertical>OR</Divider>
                </Grid.Column>

                <Grid.Column width={2}>
                  <p style={{fontSize: '13px', margin: 0, padding: 0}}>
                    Select image to 
                    find similar models.
                  </p>
                </Grid.Column>

                <Grid.Column width={2}>
                  <Button color='green'>
                    Select Image
                  </Button>
                </Grid.Column>

                </Grid>
            </Card.Content>
          </Card>
        </Container>
      </Container>
    )
  }
}
