import React, {Component, PropTypes} from 'react';
import {Table} from 'react-bootstrap';

import math from 'mathjs';
import moment from 'moment';

import merge from 'node.extend';

export function convertSize(sizeB) {
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

export function getWorkerPlatform(worker) {
  return worker.os && worker.os.platform;
}

export function getWorkerHostname(worker) {
  return worker.os && worker.os.hostname;
}

export function getWorkerUptime(worker) {
  return worker.os && worker.os.uptime && moment.utc(new Date(new Date().getTime() - (worker.os.uptime * 1000))).fromNow();
}

export function getWorkerCpus(worker) {
  if (worker.os && worker.os.cpus) {
    return `${worker.os.cpus.length} x ${worker.os.cpus[0].model}`;
  }

  return null;
}

export function getWorkerLoad(worker) {
  if (worker.os && worker.os.load) {
    return worker.os.load.map(x => { return x.toFixed(2); }).join(', ');
  }

  return null;
}

export function getWorkerMemory(worker) {
  if (worker.os && worker.os.mem) {
    const free = convertSize(worker.os.mem.free);
    const total = convertSize(worker.os.mem.total);
    const percentage = math.round((worker.os.mem.free / worker.os.mem.total) * 100, 1);

    return `${percentage}% - ${free} / ${total}`;
  }

  return null;
}

export function getWorkerFlag(worker) {
  const countryCode = worker.country_code;

  if (countryCode === null || countryCode === '' || countryCode === 'ZZ') {
    return null;
  }

  const path = `/images/flags/png/32/${countryCode}.png`;

  return (
    <img src={path} alt={countryCode} />
  );
}

export default class WorkersTable extends Component {
  static propTypes = {
    workers: PropTypes.object
  };

  render() {
    const workers = (this.props.workers && this.props.workers.workers) || [];

    return (
      <div className="container">
        <Table striped bordered condensed hover>
          <thead>
            <tr>
              {false && <th>UUID</th>}
              <th>Platform</th>
              <th>IP</th>
              <th>Country</th>
              <th>Hostname</th>
              <th>Booted</th>
              <th>CPU</th>
              <th>Load</th>
              <th>Memory</th>
            </tr>
          </thead>

          <tbody>
            {workers.map((worker) => {
              const data = merge(true, worker.join || {}, worker.ping || {});
              return (
                <tr key={data.uuid}>
                  {false && <td>{data.uuid}</td>}
                  <td>{getWorkerPlatform(data)}</td>
                  <td>{data.remote_ip}</td>
                  <td>{getWorkerFlag(worker)}</td>
                  <td>{getWorkerHostname(data)}</td>
                  <td>{getWorkerUptime(data)}</td>
                  <td>{getWorkerCpus(data)}</td>
                  <td>{getWorkerLoad(data)}</td>
                  <td>{getWorkerMemory(data)}</td>
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
