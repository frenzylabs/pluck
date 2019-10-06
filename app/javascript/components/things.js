import React              from 'react'
import { Link }         from 'react-router-dom';

const qs = require('qs');

import { Form, Input, Button, Menu, Grid, Image, Label } from 'semantic-ui-react'
import { Pagination } from 'semantic-ui-react'

export default class Things extends React.Component {
  constructor(props) {
    super(props);

    var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })
    console.log(props);
    console.log(qparams)
    this.state = {
      things: [],
      search: {
        page: parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q: qparams["q"] || ""
      },
      searchTerm: qparams["q"] || ""
    };

    this.loadThings   = this.loadThings.bind(this)
    this.searchChange = this.searchChange.bind(this)
    this.searchThings = this.searchThings.bind(this)
    this.onPageChange = this.onPageChange.bind(this)
  }

  componentDidMount(){
    this.loadThings()
  }

  componentDidUpdate(prevProps, prevState) {
    if (this.props.location.search != prevProps.location.search) {
      var qparams = qs.parse(this.props.location.search, { ignoreQueryPrefix: true })
      var search = {
        page: parseInt(qparams["page"] || 1), 
        per_page: parseInt(qparams["per_page"] || 20), 
        q: qparams["q"] || ''
      }
      this.setState({search: search})
    }
    else if (JSON.stringify(this.state.search) != JSON.stringify(prevState.search)) {
      var url = qs.stringify(this.state.search, { addQueryPrefix: true });      
      this.props.history.push(`${url}`);
      this.loadThings();
    } 
    // else {
    //   console.log(JSON.stringify(this.state.search))
    //   console.log(JSON.stringify(prevState.search))
    // }
  }

  loadThings() {
    var query = qs.stringify(this.state.search, { addQueryPrefix: true })    
    fetch('/api/v1/things.json'+ query)
      .then((response) => { return response.json()})
      .then((data) => {
        var search = this.state.search
        if (this.state.search.per_page != data.meta.per_page) {
          search.per_page = data.meta.per_page
          var url = qs.stringify(search, { addQueryPrefix: true });
          this.props.history.push(`${url}`);
        }
        this.setState({ things: data.data, search: search }) 
      });
  }

  onPageChange(e, data) {
    this.setState({search: {...this.state.search, page: data.activePage}})
  }
  searchChange(e, data) {
    this.setState({searchTerm: data.value});
  }
  searchThings() {
    this.setState({search: {...this.state.search, page: 1, q: this.state.searchTerm}})
  }

  render(){
    var things = this.state.things.map((thing) => {
      return (
        <Grid.Column key={thing.id} className={"thing"}>
            <div className={"thing-top"}>
              <Image src={`${thing.image_url}`} />
              <Label>{thing.name}</Label>
            </div>
            <Menu>
              <Menu.Item link={true} as={"a"} target="_blank" href={`http://thingiverse.com/thing:${thing.thingiverse_id}`}>
                <span>Visit</span>
              </Menu.Item>

              <a className={"link"} target="_blank" href={`http://layerkeep.local/projects/new?source=thingiverse&thing_id=${thing.thingiverse_id}`}>
                <span>Manage On Layerkeep</span>
              </a>
            </Menu>
            
        </Grid.Column>
      )
    })

    var totalPages = this.state.search.page
    if (things.length >= this.state.search.per_page) {
      totalPages = this.state.search.page + 1
    }

    return (
      <div className={"column container ui"}>
        <div className={"container"} style={{"margin": "20px"}}>
          <Form onSubmit={this.searchThings}>
            <Form.Field >
              <Input action={{ icon: 'search' }} onChange={this.searchChange} placeholder='Search...' value={this.state.searchTerm} />
            </Form.Field>
          </Form>
        </div>
        <div className={"container"}>
          <Grid doubling columns={5}>
            {things}
          </Grid>
        </div>
        <Pagination
          boundaryRange={0}
          defaultActivePage={this.state.search.page}
          ellipsisItem={null}
          firstItem={null}
          lastItem={null}
          siblingRange={1}
          totalPages={totalPages}
          onPageChange={this.onPageChange}
          style={{"margin": "20px"}}
        />
      </div>
    )
  }
}
