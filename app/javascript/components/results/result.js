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
  Image,
  Popup,
  Dimmer
} from 'semantic-ui-react'

export default class Result extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      dimmed: true
    }
  }

  render() {

    let url   = this.props.image
    let lurl  = (url == null || url.length == 0) ? "/assets/image-placeholder.png" : url.replace(/(thumb_)(medium)(\.)/, '$1large$3')

    const bgStyle = {
      backgroundImage: `url(${lurl})`, 
      backgroundSize: 'cover', 
      backgroundRepeat: 'no-repeat', 
      backgroundPosition: '50% 0',
      height: '200px'
    }

    return (
      <div className="column" style={{overflow: 'hidden', cursor: 'pointer'}}>
        <div className="ui card">
        <Dimmer.Dimmable as="div">
        <Dimmer active={this.state.dimmed}>
          <div className="ui blurring image" style={bgStyle}>
              <div className="card-hover-content">
                <div style={{display: 'flex', flex: 1}}>

                  <div className="card-hover-description">
                    <p className="card-hover-content-truncate">{this.props.item.description}</p>
                  </div>

                  <div className="hover-link">
                    <a className="ui icon button" href="#">
                      <i className="large upload icon"></i>
                    </a>
                  </div>
                </div>
              </div>

            <img src={lurl} style={{opacity: 0}}/>

          </div>
          </Dimmer>
          </Dimmer.Dimmable>

          <div className="content">
            <div className="description hover-name">{this.props.item.name}</div>
          </div>

        </div>
      </div> 
    )
  }
}
