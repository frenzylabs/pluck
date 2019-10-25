//
//  application.js
//  pluck
// 
//  Created by Wess Cope (me@wess.io) on 10/15/19
//  Copyright 2019 Wess Cope
//

import React        from 'react'
import ReactDOM     from 'react-dom'
import { BrowserRouter }  from 'react-router-dom'
import App    from '../app'


document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <BrowserRouter >
      <App />
    </BrowserRouter>, document.getElementById('app'))
});
