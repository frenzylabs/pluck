/*
 *  list.js
 *  LayerKeep
 * 
 *  Created by Wess Cope (me@wess.io) on 04/26/19
 *  Copyright 2018 WessCope
 */

import React from 'react';
import qs from 'qs'

import { Container, Breadcrumb, BreadcrumbItem, Pagination, PageControl, PageList, Page, PageLink, PageEllipsis }    from 'bloomer';
import PropTypes from 'prop-types';

const propTypes = {
    onChangePage: PropTypes.func,
    currentPage: PropTypes.number,
    lastPage: PropTypes.number,
    totalItems: PropTypes.number,
    pageSize: PropTypes.number
}

const defaultProps = {
    currentPage: 1,
    pageSize: 10
}

class PaginatedList extends React.Component {
  constructor(props) {
    super(props);
    this.state = { pager: {} };
  }

  UNSAFE_componentWillMount() {
      // set page if items total isn't empty
      if (this.props.totalItems > 1) {
          this.setPage(null, this.props.currentPage);
      }
  }

  componentDidUpdate(prevProps, prevState) {
      if (this.props.totalItems !== prevProps.totalItems ||
        this.props.pageSize !== prevProps.pageSize || this.props.currentPage != prevProps.currentPage) {
          this.setPage(null, this.props.currentPage);
      }
  }

  setPage(e, page) {
    var { totalItems, pageSize, totalPages } = this.props;
    var pager = this.state.pager;

    if (page < 1 || page > totalPages) {
        return;
    }

    // get new pager object for specified page
    pager = this.getPager(totalItems, page, totalPages, pageSize);

    // get new page of items from items array

    // update state
    this.setState({ pager: pager });

    // call change page function in parent component
    if (this.props.onChangePage) {
      if (e) {
        e.preventDefault()
        e.stopPropagation()
        this.props.onChangePage(page);
      }
      
      
    }
  }


  getPager(totalItems, currentPage, totalPages, pageSize) {
    // default to first page
    currentPage = currentPage || 1;

    // default page size is 10
    pageSize = pageSize || 10;

    // calculate total pages

    var startPage, endPage;
    if (totalPages <= 10) {
        // less than 10 total pages so show all
        startPage = 1;
        endPage = totalPages;
    } else {
        // more than 10 total pages so calculate start and end pages
        if (currentPage <= 6) {
            startPage = 1;
            endPage = 10;
        } else if (currentPage + 4 >= totalPages) {
            startPage = totalPages - 9;
            endPage = totalPages;
        } else {
            startPage = currentPage - 5;
            endPage = currentPage + 4;
        }
    }

    // create an array of pages to loop in the pager control
    var pages = [...Array((endPage + 1) - startPage).keys()].map(i => startPage + i);

    // return object with all pager properties required by the view
    return {
        totalItems: totalItems,
        currentPage: currentPage,
        pageSize: pageSize,
        totalPages: totalPages,
        startPage: startPage,
        endPage: endPage,
        pages: pages
    };
  }


  renderLink(page) {
    let linkpage;
    if (this.props.location && this.props.location.search) {
      const {page: curpage, per_page, q} = qs.parse(this.props.location.search, {ignoreQueryPrefix: true})
      linkpage = {page, per_page, q}
    } else {
      const per_page = this.state.pager.pageSize
      linkpage = {page, per_page}
    }  
    return qs.stringify(linkpage, { addQueryPrefix: true })
  }

  render() {
    var pager = this.state.pager;

    if (!pager.pages || pager.pages.length <= 1) {
        // don't display pager if there is only 1 page
        return null;
    }

    return (
        <div className="container is-fluid">
          <nav className="pagination is-centered">
            <a className="pagination-previous" {...(pager.currentPage <= 1  ? {disabled: true} : "")} onClick={(e) => this.setPage(e, pager.currentPage-1)} >Previous</a>
            <a className="pagination-next" {...(pager.currentPage >= pager.totalPages ? {disabled: true} : "")} onClick={(e) => this.setPage(e, pager.currentPage + 1)}>Next</a>
            <ul className="pagination-list">
              {pager.pages.map((page, index) =>
                <li key={index} >
                <a href={this.renderLink(page)} className={`pagination-link ${pager.currentPage == page ? 'is-current' : ''}`} onClick={(e) => this.setPage(e, page)}>{page}</a>
              </li>                    
            )}
            </ul>
          </nav>
        </div>)
  }
}

PaginatedList.propTypes = propTypes;
PaginatedList.defaultProps = defaultProps;
export default PaginatedList;
