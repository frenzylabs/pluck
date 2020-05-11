//
//  index.tsx
//  pluck
// 
//  Created by Wess Cope (wess@frenzylabs.com) on 04/22/20
//  Copyright 2020 FrenzyLabs LLC.
//

import React  from 'react'
import Logo   from '../../assets/images/pluck-logo.svg'

// import "./nav.scss";

class TopNav extends React.Component {
  state = {
    term: ""
  }

  constructor(props) {
    super(props)

    this.updateTerm = this.updateTerm.bind(this)
    this.search     = this.search.bind(this)
    this.renderForm = this.renderForm.bind(this)
  }

  updateTerm(e) {
    this.setState({
      term: e.target.value
    })
  }

  search(e) {
    e.preventDefault()

    this.props.handleSearch(this.state.term)
  }

  renderForm() {
    return (
      <form onSubmit={this.search}>
        <div className="control has-icons-right">
          <input disabled={this.props.disabled} className="input is-small" type="text" placeholder="Search.." value={this.state.term} onChange={this.updateTerm} />

          <span className="icon is-small is-right">
            <i className="fas fa-search fa-xs"/>
          </span>
        </div>
      </form>
    )
  }

  renderBrand() {
    return (
      <div className="navbar-brand">
        <a className="navbar-item" href="/">
          <img src={Logo} alt="Pluck: Free 3D printing model search" width="40" height="28" />
          <h1 className="is-hidden-mobile">Pluck</h1>
        </a>


        <div className="navbar-item is-expanded is-hidden-desktop">
          <div className="container is-fluid">
            {this.renderForm()}
          </div>
        </div>
      </div>
    )
  }

  renderSearch() {
    return (
      <div className="navbar-item is-expanded">
        <div className="container is-fluid">
          {this.renderForm()}
        </div>
      </div>
    )
  }

  renderEnd() {
    return (
      <div className="navbar-end">
        <div className="navbar-item">
          <a className="button is-success is-outlined layerkeep" href="https://layerkeep.com" target="_blank">
            <span>LayerKeep</span> 

            <span className="icon">
              <i className="fas fa-angle-right"></i>
            </span>
          </a>
        </div>
      </div>
    )
  }

  render() {
    return (
      <nav id="top-nav" className="navbar is-fixed-top is-transparent" role="navigation" aria-label="main navigation">
        {this.renderBrand()}

        <div className="navbar-menu">
          {this.renderSearch()}

          {this.renderEnd()}
        </div>
      </nav>
    )
  }
}

export default TopNav

