import React, {Component, PropTypes} from 'react';

import Helmet from 'react-helmet';

import {connect} from 'react-redux';

import CrawlersTable from '../../components/CrawlersTable';

import * as crawlersActions from '../../redux/modules/crawlers';

@connect(
  (state) => ({
    crawlers: state.crawlers
  }),
  {
    ...crawlersActions
  }
)
export default class Crawlers extends Component {
  static propTypes = {
    crawlers: PropTypes.object,
    crawlersGetList: PropTypes.func,
    enqueueUrl: PropTypes.func
  };

  componentDidMount() {
    this.props.crawlersGetList();
  }

  render() {
    return (
      <div className="container">
        <Helmet title="Crawlers" />

        <CrawlersTable crawlers={this.props.crawlers} enqueueUrl={this.props.enqueueUrl} />
      </div>
    );
  }
}

