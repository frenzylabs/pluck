//
//  index.jsx
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/23/20
//  Copyright 2020 FrenzyLabs LLC.
//

import React from 'react'

// import './pagination.scss'

export default class extends React.Component {
  pageHandler(index) {
    
  }

  renderItem(position, icon) {
    return (
      <li>
        <a className="pagination-link" aria-label={`Goto ${position} page`}>
          <span className="icon">
            <i className={`fas fa-angle-${icon}`}></i>
          </span>
        </a>
      </li>
    )
  }

  renderIndex(index) {
    return (
      <li key={`page-${index}`}>
        <a className="pagination-link" aria-label={`Goto page ${index} page`} data-page={index + 1} onClick={() => this.pageHandler(index)}>
          {index}
        </a>
      </li>
    )
  }

  renderIndices() {
    var lines = []

    for(var i = 0; i < this.props.totalPages; i++) {
      lines.push(
        this.renderIndex(i + 1)
      )
    }

    return lines
  }
  
  render() {
    return (
      <div id="pagination" className="container">
        <nav className="pagination is-centered" role="navigation" aria-label="pagination">
          <ul className="pagination-list">
            {this.renderItem("first", "double-left")}
            {this.renderItem("previous", "left")}

            {this.renderIndices()}

            {this.renderItem("next", "right")}
          </ul>
        </nav>
      </div>
    )
  }
}
