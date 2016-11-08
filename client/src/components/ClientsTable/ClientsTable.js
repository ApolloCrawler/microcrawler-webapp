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

export function getClientPlatform(client) {
  return client.os && client.os.platform;
}

export function getClientHostname(client) {
  return client.os && client.os.hostname;
}

export function getClientUptime(client) {
  return client.os && client.os.uptime && moment.utc(new Date(new Date().getTime() - (client.os.uptime * 1000))).fromNow();
}

export function getClientCpus(client) {
  if (client.os && client.os.cpus) {
    return `${client.os.cpus.length} x ${client.os.cpus[0].model}`;
  }

  return null;
}

export function getClientLoad(client) {
  if (client.os && client.os.load) {
    return client.os.load.map(x => { return x.toFixed(2); }).join(', ');
  }

  return null;
}

export function getClientMemory(client) {
  if (client.os && client.os.mem) {
    const free = convertSize(client.os.mem.free);
    const total = convertSize(client.os.mem.total);
    const percentage = math.round((client.os.mem.free / client.os.mem.total) * 100, 1);

    return `${percentage}% - ${free} / ${total}`;
  }

  return null;
}

export function getClientFlag(client) {
  const countryCode = client.join.country_code;

  if (!countryCode || countryCode === null || countryCode === '' || countryCode === 'ZZ') {
    return null;
  }

  const path = `/images/flags/png/32/${countryCode}.png`;

  return (
    <img src={path} alt={countryCode} />
  );
}

export default class CrawlersTable extends Component {
  static propTypes = {
    clients: PropTypes.object
  };

  render() {
    const clients = (this.props.clients && this.props.clients.clients) || [];

    return (
      <div className="container">
        <h1>Clients</h1>

        <Table striped bordered condensed hover>
          <thead>
            <tr>
              {false && <th>UUID</th>}
              <th>Platform</th>
              <th>IP</th>
              <th>Country</th>
              <th>User Agent</th>
            </tr>
          </thead>

          <tbody>
            {clients.map((client) => {
              const data = merge(true, client.join || {}, client.ping || {});
              return (
                <tr key={data.uuid}>
                  {false && <td>{data.uuid}</td>}
                  <td>{getClientPlatform(data)}</td>
                  <td>{data.remote_ip}</td>
                  <td>{getClientFlag(client)}</td>
                  <td />
                </tr>
              );
            })}
          </tbody>
        </Table>
      </div>
    );
  }
}
