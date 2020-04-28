//
//  index.jsx
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/27/20
//  Copyright 2020 FrenzyLabs LLC.
//

import './details.scss'

import React from 'react'

import {
  Button,
  Header,
  Image,
  Modal
} from 'semantic-ui-react'


export default class extends React.Component {
  backgroundImage(url) {
    let lurl  = (url == null || url.length == 0) ? "/assets/image-placeholder.png" : url.replace(/(thumb_)(medium)(\.)/, '$1large$3')

    return {
      backgroundImage:    `url(${lurl})`,
      backgroundSize:     "cover",
      backgroundRepeat:   "no-repeat",
      backgroundPosition: "50% 0",
      height:             '680px'
    }
  }

  renderHeader() {
    return (
      <div className="details-header">
        <div className="title-line">
          <h1 className="title is-5">
            {this.props.item.name}
          </h1>

          {this.props.item.user && this.props.item.user.name && (
            <p className="heading">
              by <a href={`https://www.thingiverse.com/${this.props.item.user.name}`} target="_blank">
                  {this.props.item.user.name}
                </a>
            </p>
          )}
        </div>

        <div className="details-button">
          <a 
            className="button is-success"
            href={`${window.currentEnv.domains.layerkeep}/projects/new?source=thingiverse&thing_id=${this.props.item.thingiverse_id}`}
            target="_blank"
          >
            Create on LayerKeep
          </a>
        </div>
      </div>
    )
  }

  renderImage() {
    return (
      <figure className="image is-16by9 details-image" style={this.backgroundImage(this.props.item.image_url)}>
      </figure>
    )
  }

  renderDescription() {
    return (
      <div className="details-description">
        <div className="columns">
          <div className="column">
            <p style={{marginRight: '10px'}}>
              {this.props.item.description.split("\n").map((item, idx) => <span key={idx}>{item}<br/></span>)}
            </p>
          </div>

          <div className="column is-3">
            <div className="buttons">
              <a 
                className="button is-success is-fullwidth"
                href={`${window.currentEnv.domains.layerkeep}/projects/new?source=thingiverse&thing_id=${this.props.item.thingiverse_id}`}
                target="_blank"
              >
                Create on LayerKeep
              </a>

              <a 
                className="button is-fullwidth"
                href={`${window.currentEnv.domains.thingiverse}/thing:${this.props.item.thingiverse_id}`}
                target="_blank"
              >
                View on Thingiverse
              </a>
            </div>

            {this.props.item.categories && (
              <div className="details-tag">
                <h2 className="title is-6">Categories</h2>
                <div className="tags">
                  {this.props.item.categories.map((cat, idx) => <span key={idx} className="tag">{cat.name}</span>)}
                </div>
              </div>
            )}

          </div>
        </div>
      </div>
    )
  }

  render() {
    return(
      <div id="details" className="columns is-centered">
        <div className="column is-8 details-body">
          {this.renderHeader()}

          {this.renderImage()}

          {this.renderDescription()}
        </div>
      </div>
    )
  }
}
