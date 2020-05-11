//
//  index.jsx
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/23/20
//  Copyright 2020 FrenzyLabs LLC.
//

import React from 'react'

import './loading.scss'

export default class extends React.Component {

  renderCube() {
    return (
      <div id="cube">
        <div id="panels">
          <div className="panel"></div>
          <div className="panel"></div>
          <div className="panel"></div>
          <div className="panel"></div>
          <div className="panel"></div>
          <div className="panel"></div>
        </div>
      </div>
    )
  }

  render() {
    return (
      <div id="loading-modal" className="modal is-active">
        <div className="modal-background"></div>

        <div className="modal-card">
          <section className="modal-card-body">
            <div className="container">
              <div className="columns is-vcentered">
                <div className="column is-narrow">
                  {this.renderCube()}
                </div>

                <div className="column is-8">
                  <h1 className="is-size-4 has-text-centered has-text-gray has-text-weight-semibold">{this.props.message || "Searching..."}</h1>
                </div>
              </div>
            </div>
          </section>
        </div>        
      </div>
    )
  }
}
