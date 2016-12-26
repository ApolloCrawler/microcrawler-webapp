import React, {Component, PropTypes} from 'react';

import Helmet from 'react-helmet';

import {connect} from 'react-redux';

import CrawlersTable from '../../components/CrawlersTable';

import * as crawlersActions from '../../redux/modules/crawlers';
import * as socketActions from '../../redux/modules/socket';

@connect(
  (state) => ({
    crawlers: state.crawlers
  }),
  {
    ...crawlersActions,
    ...socketActions
  }
)
export default class Crawlers extends Component {
  static propTypes = {
    crawlers: PropTypes.object,
    crawlersGetList: PropTypes.func,
    socketMessageSend: PropTypes.func
  };

  componentDidMount() {
    this.props.crawlersGetList();
  }

  render() {
    return (
      <div className="container">
        <Helmet title="Crawlers" />

        <CrawlersTable
          crawlers={this.props.crawlers}
          enqueueUrl={
            (url, crawler) => {
              console.log(url, crawler);
              const msg = {
                crawler: `${crawler.name}/index`,
                url
              };
              this.props.socketMessageSend('client:lobby', 'enqueue', msg);
            }
          }
        />
      </div>
    );
  }
}

