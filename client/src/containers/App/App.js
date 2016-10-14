import React, { Component, PropTypes } from 'react';

import Helmet from 'react-helmet';

import { connect } from 'react-redux';
import { push } from 'react-router-redux';

import { IndexLink } from 'react-router';
import { LinkContainer } from 'react-router-bootstrap';

import Nav from 'react-bootstrap/lib/Nav';
import Navbar from 'react-bootstrap/lib/Navbar';
import NavItem from 'react-bootstrap/lib/NavItem';

import { Socket } from 'phoenix';

import config from '../../config';
import logger from '../../helpers/logger';

import * as workerActions from '../../redux/modules/workers';

@connect(
  state => ({
    user: state.user
  }),
  {
    pushState: push,
    ...workerActions
  }
)
export default class App extends Component {
  static propTypes = {
    children: PropTypes.object.isRequired,

    // workersAdd: PropTypes.func,
    workersClean: PropTypes.func,
    workersRemove: PropTypes.func,
    // workersSet: PropTypes.func,
    workersUpdate: PropTypes.func,
  };

  componentDidMount() {
    const socket = new Socket('/socket', {
      params: { token: window.userToken || null },
      logger: (kind, msg, data) => {
        logger.debug(`${kind}: ${msg}`, data);
      }
    });
    socket.connect();

    const channel = socket.channel('client:lobby', {});
    channel.join()
      .receive('error', () => {
        logger.error('Connection error');
      });

    channel.on('clear_worker_list', () => {
      this.props.workersClean();
    });

    // TODO: Rename to worker_remove
    channel.on('remove_worker', (payload) => {
      this.props.workersRemove(payload);
    });

    // TODO: Rename to worker_update
    channel.on('update_worker', (payload) => {
      this.props.workersUpdate(payload);
    });
  }

  render() {
    const styles = require('./App.scss');

    return (
      <div className={styles.app}>
        <Helmet title="Main" titleTemplate="Microcrawler | %s"/>

        <Navbar fixedTop>
          <Navbar.Header>
            <Navbar.Brand>
              <IndexLink to="/" activeStyle={{ color: '#33e0ff' }}>
                <span className={styles.brand} />
                <span>{config.app.name}</span>
              </IndexLink>
            </Navbar.Brand>
            <Navbar.Toggle/>
          </Navbar.Header>

          <Navbar.Collapse>
            <Nav navbar>
              <LinkContainer to="/">
                <NavItem>Workers</NavItem>
              </LinkContainer>
            </Nav>
          </Navbar.Collapse>
        </Navbar>

        <div className={styles.appContent}>
          {this.props.children}
        </div>
      </div>
    );
  }
}
