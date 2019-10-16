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
  Container 
} from 'semantic-ui-react'

import Headline from './components/headline'
import Results  from './components/results'
import Footer   from './components/footer'
import Things   from './components/things.js'

export class App extends React.Component {
  constructor(props) {
     super(props)
  }

  render() {
    return (
      <React.Fragment>
        <Headline />
        <Results/>
        <Footer/>
      </React.Fragment>
    )
  }
}

export default withRouter(App)

/*
<div className={"container"}>
<Header as='h1' inverted textAlign='center' style={{marginTop: '20px'}}>
  Search for 3D Models
  <Header.Subheader>
    
  </Header.Subheader>
</Header>
<Divider />
<Grid container celled='internally' columns={3} className="center aligned">
  <Grid.Row>
    <Grid.Column width={2}>
      
    </Grid.Column>
    <Grid.Column width={10}>
      <Things {...this.props} />    
    </Grid.Column>
    <Grid.Column width={2}>
    </Grid.Column>
  </Grid.Row>
</Grid>


</div>
*/
