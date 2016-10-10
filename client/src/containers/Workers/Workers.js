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

    const getWorkerPlatform = (worker) => {
      return worker.ping && worker.ping.os.platform;
    };

    const getWorkerHostname = (worker) => {
      return worker.ping && worker.ping.os.hostname;
    };

    const getWorkerUptime = (worker) => {
      return worker.ping && moment.utc(new Date(new Date().getTime() - (worker.ping.os.uptime * 1000))).fromNow();
    };

    const getWorkerCpus = (worker) => {
      if (worker.ping) {
        return `${worker.ping.os.cpus.length} x ${worker.ping.os.cpus[0].model}`;
      }

      return null;
    };

    const getWorkerLoad = (worker) => {
      if (worker.ping) {
        return worker.ping.os.load.map(x => { return x.toFixed(2); }).join(', ');
      }

      return null;
    };

    const getWorkerMemory = (worker) => {
      if (worker.ping) {
        const free = convertSize(worker.ping.os.mem.free);
        const total = convertSize(worker.ping.os.mem.total);
        const percentage = math.round((worker.ping.os.mem.free / worker.ping.os.mem.total) * 100, 1);

        return `(${percentage}%) - ${free} / ${total}`;
      }

      return null;
    };

    return (
      <div className="container">
        <Helmet title="Workers" />

        <h1>Workers</h1>

        <Table striped bordered condensed hover>
          <thead>
            <tr>
              {false && <th>UUID</th>}
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
                  {false && <td>{worker.join.uuid}</td>}
                  <td>{getWorkerPlatform(worker)}</td>
                  <td>{getWorkerHostname(worker)}</td>
                  <td>{getWorkerUptime(worker)}</td>
                  <td>{getWorkerCpus(worker)}</td>
                  <td>{getWorkerLoad(worker)}</td>
                  <td>{getWorkerMemory(worker)}</td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
