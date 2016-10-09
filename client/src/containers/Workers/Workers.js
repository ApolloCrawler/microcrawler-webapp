import React, {Component, PropTypes} from 'react';
import {Table} from 'react-bootstrap';

import {connect} from 'react-redux';

import * as workerActions from '../../redux/modules/workers';

@connect(
  (state) => ({
    workers: state.workers.workers
  }),
  {
    ...workerActions
  }
)
export default class Workers extends Component {
  static propTypes = {
    workers: PropTypes.array
  };

  render() {
    const workers = this.props.workers || [];

    return (
      <div className="container">
        <h1>Workers</h1>

        <Table striped bordered condensed hover>
          <thead>
            <tr>
              <th>UUID</th>
              <th>Platform</th>
              <th>Hostname</th>
              <th>Uptime</th>
              <th>Load</th>
            </tr>
          </thead>

          <tbody>
            {workers.map((worker) => {
              return (
                <tr key={worker.join.uuid}>
                  <td>{worker.join.uuid}</td>
                  <td>{worker.ping && worker.ping.os.platform}</td>
                  <td>{worker.ping && worker.ping.os.hostname}</td>
                  <td>{worker.ping && worker.ping.os.uptime}</td>
                  <td>{worker.ping && worker.ping.os.load.join(', ')}</td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
