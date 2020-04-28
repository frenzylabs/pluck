//
//  index.jsx
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/22/20
//  Copyright 2020 FrenzyLabs LLC.
//
import './results.scss'

import React    from 'react'
import Truncate from 'react-truncate'
import Details  from '../details'

export default class extends React.Component {

  state = {
    presentedItem: null
  }

  constructor(props) {
    super(props)

    this.modalEsc   = this.modalEsc.bind(this)
    this.escToggle  = this.escToggle.bind(this)
    this.get        = this.get.bind(this)
  }

  modalEsc(e) {
    if(e.keyCode === 27) {
      this.setState({presentedItem: null})  
    }    
  }

  escToggle() {
    if(this.state.presentedItem) {
      document.addEventListener("keypress", this.modalEsc, false)

      Array.prototype.slice.call(document.querySelectorAll('.modal-background')).forEach((el) => {
        el.addEventListener('click', this.modalEsc)
      })
    } else {
      document.removeEventListener("keypress", this.modalEsc, false)
    }
  }

  componentDidMount() {
    const [_, path, id] = this.props.location.pathname.split('/')

    if(path.toLowerCase() == "things") {
      this.get(id)
    }
  }

  componentWillUnmount() {
    document.removeEventListener("keypress", this.modalEsc, false)
  }

  backgroundImage(url) {
    let lurl  = (url == null || url.length == 0) ? "/assets/image-placeholder.png" : url.replace(/(thumb_)(medium)(\.)/, '$1large$3')

    return {
      backgroundImage:    `url(${lurl})`,
      backgroundSize:     "cover",
      backgroundRepeat:   "no-repeat",
      backgroundPosition: "50% 0"
    }
  }

  get(id) {
    fetch(`/things/${id}.json`)
    .then(res => res.json())
    .then(data => {
      console.log("DD: ", data)
      this.setState({
        presentedItem: {attributes: data}
      })
    })
    .catch(err => console.log("ERR: ", err))
  }

  renderColumn(key, item) {
    return (
      <div key={key} className="column is-one-third is-narrow">
        <div className="card">
          <a className="card-image" href={`/things/${item.id}`} onClick={(e) => {
            e.preventDefault()
            this.setState({presentedItem: item})
          }}>
            <figure style={this.backgroundImage(item.attributes.image_url)}>
              <div className="item-content">
                <div className="columns">
                  <div className="column is-9">
                    <article>
                      <Truncate lines={2}>
                        {(item.attributes.description || "").split('\n').join(' ')}
                      </Truncate>
                    </article>
                  </div>

                  <div className="column">
                    <button className="button" onClick={(e) => {
                      e.stopPropagation()
                      
                      window.open(
                        `${window.currentEnv.domains.layerkeep}/projects/new?source=thingiverse&thing_id=${item.thingiverse_id}`,
                        "_blank"
                      )
                    }}>
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
    this.escToggle()
    
    return (
      <>
        <div id="results" className="container">
          <div className="columns is-multiline is-centered">
            {this.props.items && this.props.items.map((item, index) => this.renderColumn(index, item))}
          </div>
        </div>

        <div 
          className={`modal ${this.state.presentedItem == null ? '' : 'is-active'}`} 
        >
          <div className="modal-background"></div>

          <div className="modal-content container is-fluid">
            {this.state.presentedItem && (
              <Details item={this.state.presentedItem.attributes}/>
            )}
          </div>
          <button 
            className="modal-close is-large" 
            aria-label="close" 
            onClick={() => this.setState({presentedItem: null})}>
          </button>
        </div>
      </>
    )
  }
}
