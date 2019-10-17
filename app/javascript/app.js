import React              from 'react'
import {
  withRouter
} from 'react-router-dom'
import { 
  Header, 
  Divider, 
  Grid, 
  Image, 
  Label, 
  Container, 
  Menu,
  Item,
  Button,
  Input,
  Card,
  Advertisement
} from 'semantic-ui-react'

import Master   from './components/master'
import Headline from './components/headline'
import Results  from './components/results'
import Footer   from './components/footer'
import Things   from './components/things.js'

export class App extends React.Component {
  constructor(props) {
     super(props)

      this.state = {
        results: []
      }

     this.updateResults = this.updateResults.bind(this)
  }

  updateResults(results) {
    this.setState({
      results: results
    })
  }

  render() {
    return (
      <Container fluid id="master-detail">
        <Grid stretched columns='equal' className="main-content">
            <Grid.Column width={3} id="left-menu" only='computer'>
              <Master {...this.props} updateResults={this.updateResults} />
            </Grid.Column>

            <Grid.Column id="master-content">
              <Headline/>


              <Container fluid style={{overflowX: 'hidden', overflowY: 'auto', height:'100%', minHeight: '100%'}}>
                <div style={{padding: '40px 0'}}>
                  <Results {...this.props} items={this.state.results} />
                </div>
              </Container>
            </Grid.Column>
        </Grid>
      </Container>
    )
  }
}

export default withRouter(App)
