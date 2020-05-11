// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);


import React              from 'react'
import ReactDOM           from 'react-dom'
import { BrowserRouter }  from 'react-router-dom'


import App from '../index'

document.addEventListener('DOMContentLoaded', () => {
  const htmlTag = document.getElementsByTagName('html')[0]

  ReactDOM.render(
    <BrowserRouter>
      <App />
    </BrowserRouter>, document.getElementById('app'))
});