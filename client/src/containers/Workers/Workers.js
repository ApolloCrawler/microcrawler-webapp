import React, {Component, PropTypes} from 'react';
import {Table} from 'react-bootstrap';

import Helmet from 'react-helmet';

import {connect} from 'react-redux';
import math from 'mathjs';
import moment from 'moment';

import * as workerActions from '../../redux/modules/workers';

function convertSize(sizeB) {
  const units = [
    'B',
    'kB',
    'MB',
    'GB'
  ];

  let i = 0;
  let res = sizeB;
  while (res >= 1024 && (i + 1 < units.length)) {
    res /= 1024;
    i += 1;
  }

  return `${math.round(res, 2)} ${units[i]}`;
}

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
    const workers = (this.props.workers && this.props.workers.workers) || [];

    return (
      <div className="container">
        <Helmet title="Workers" />

        <h1>Workers</h1>

        <Table striped bordered condensed hover>
          <thead>
            <tr>
              <th>UUID</th>
              <th>Platform</th>
              <th>Hostname</th>
              <th>Booted</th>
              <th>CPU</th>
              <th>Load</th>
              <th>Memory</th>
            </tr>
          </thead>

          <tbody>
            {workers.map((worker) => {
              return (
                <tr key={worker.join.uuid}>
                  <td>{worker.join.uuid}</td>
                  <td>{worker.ping && worker.ping.os.platform}</td>
                  <td>{worker.ping && worker.ping.os.hostname}</td>
                  <td>{worker.ping && moment.utc(new Date(new Date().getTime() - (worker.ping.os.uptime * 1000))).fromNow()}</td>
                  <td>{worker.ping && worker.ping.os.cpus.length} x {worker.ping && worker.ping.os.cpus[0].model}</td>
                  <td>{worker.ping && worker.ping.os.load.map(x => { return x.toFixed(2); }).join(', ')}</td>
                  <td>{worker.ping && convertSize(worker.ping.os.mem.free)} / {worker.ping && convertSize(worker.ping.os.mem.total)}</td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
