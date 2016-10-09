import React, { Component, PropTypes } from 'react';
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

@connect(
  state => ({
    user: state.user
  }),
  { pushState: push })
export default class App extends Component {
  static propTypes = {
    children: PropTypes.object.isRequired
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
  }

  render() {
    const styles = require('./App.scss');

    return (
      <div className={styles.app}>
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
                <NavItem>Home</NavItem>
              </LinkContainer>
              <LinkContainer to="/workers">
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
