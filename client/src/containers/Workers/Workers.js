import React, {Component, PropTypes} from 'react';

import Helmet from 'react-helmet';

import {connect} from 'react-redux';

import * as workerActions from '../../redux/modules/workers';

import WorkersTable from '../../components/WorkersTable';

@connect(
  (state) => ({
    workers: state.workers
  }),
  {
    ...workerActions
  }
)
export default class Workers extends Component {
  static propTypes = {
    workers: PropTypes.object
  };

  render() {
    return (
      <div className="container">
        <Helmet title="Workers" />

        <WorkersTable workers={this.props.workers} />
      </div>
    );
  }
}
