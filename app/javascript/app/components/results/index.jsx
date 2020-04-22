//
//  index.jsx
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/22/20
//  Copyright 2020 FrenzyLabs LLC.
//

import React    from 'react'
import Truncate from 'react-truncate'

import './results.scss'

export default class extends React.Component {


  backgroundImage(url) {
    let lurl  = (url == null || url.length == 0) ? "/assets/image-placeholder.png" : url.replace(/(thumb_)(medium)(\.)/, '$1large$3')

    return {
      backgroundImage: `url(${lurl})`,
      backgroundSize: "cover",
      backgroundRepeat: "no-repeat",
      backgroundPosition: "50% 0"
    }
  }

  renderColumn(key, item) {
    return (
      <div key={key} className="column is-one-third is-narrow">
        <div className="card">
          <a className="card-image">
            <figure className="" style={this.backgroundImage(item.attributes.image_url)}>
              <div className="item-content">
                <div className="columns">
                  <div className="column is-9">
                    <article>
                      <Truncate lines={2}>
                        {item.attributes.description.split('\n').join(' ')}
                      </Truncate>
                    </article>
                  </div>

                  <div className="column">
                    <button className="button">
                      <span className="icon is-small">
                        <i className="fas fa-layer-plus"></i>
                      </span>
                    </button>
                  </div>
                </div>
              </div>
            </figure>
          </a>

          <div className="card-content">
            <p className="truncated">{item.attributes.name}</p>
          </div>
        </div>
      </div>
    )
  }

  render() {
    return (
      <div id="results" className="container">
        <div className="columns is-multiline is-centered">
          {this.props.items.map((item, index) => this.renderColumn(index, item))}
        </div>
      </div>
    )
  }
}

//style="background-image: url('<%= lurl %>'); background-size: cover; background-repeat: no-repeat; background-position: 50% 0;"
