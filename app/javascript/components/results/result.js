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
  constructor(props) {
    super(props)

    this.renderImage = this.renderImage.bind(this)
  }


  renderImage(url) {
    let lurl = (url == null || url.length == 0) ? "/assets/image-placeholder.png" : url.replace(/(thumb_)(medium)(\.)/, '$1large$3')

    return (
      <Image 
        src={`${lurl}`} 
        wrapped 
        ui={false}
      />
    )
  }

  renderThingiverse() {
    return(
      <Button
        size='tiny'
        compact
        as='a'
        target='_blank'
        className='external-name'
        href={`${window.currentEnv.domains.thingiverse}/thing:${this.props.tid}`}
      >
        <span>Thingiverse</span>
      </Button>
    )
  }

  renderLayerKeep() {
    return(
      <Button
        size='tiny'
        compact
        primary
        as='a'
        target='_blank'
        className="layerkeep-manage"
        href={`${window.currentEnv.domains.layerkeep}/projects/new?source=thingiverse&thing_id=${this.props.tid}`}
      >
        Manage on LayerKeep
      </Button>
    )
  }

  render() {
    return (
      <Card style={{width: '220px'}}>
        {this.renderImage(this.props.image)}
        <Card.Content>
          <Card.Description>
            {this.props.name}
          </Card.Description>
        </Card.Content>
        <Card.Content extra style={{padding: '10px', margin: 0}}>
          <Button.Group fluid>
            {this.renderLayerKeep()}
            {this.renderThingiverse()}
          </Button.Group>
        </Card.Content>
      </Card>
    )
  }
}
