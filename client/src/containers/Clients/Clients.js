import React, {Component, PropTypes} from 'react';

import Helmet from 'react-helmet';

import {connect} from 'react-redux';

import ClientsTable from '../../components/ClientsTable';

@connect(
  (state) => ({
    clients: state.clients
  })
)
export default class Clients extends Component {
  static propTypes = {
    clients: PropTypes.object
  };

  render() {
    return (
      <div className="container">
        <Helmet title="Clients" />

        <ClientsTable workers={this.props.clients} />
      </div>
    );
  }
}

