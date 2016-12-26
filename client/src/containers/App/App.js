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

import * as authActions from '../../redux/modules/auth';
import * as socketActions from '../../redux/modules/socket';
import * as workerActions from '../../redux/modules/workers';

@connect(
  state => ({
    user: state.auth.user
  }),
  {
    pushState: push,
    ...authActions,
    ...socketActions,
    ...workerActions
  }
)
export default class App extends Component {
  static propTypes = {
    children: PropTypes.object.isRequired,

    user: PropTypes.object,

    pushState: PropTypes.func.isRequired,
    signOut: PropTypes.func,

    socketSet: PropTypes.func,
    socketChannelSet: PropTypes.func,

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

    this.props.socketSet(socket);

    const channelName = 'client:lobby';
    const channel = socket.channel(channelName, {});
    channel.join()
      .receive('error', () => {
        logger.error('Connection error');
      });

    channel.on('clear_worker_list', () => {
      this.props.workersClean();
    });

    this.props.socketChannelSet(channelName, channel);

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
              {this.props.user &&
                <LinkContainer to="clients">
                  <NavItem>Clients</NavItem>
                </LinkContainer>
              }

              {this.props.user &&
                <LinkContainer to="crawlers">
                  <NavItem>Crawlers</NavItem>
                </LinkContainer>
              }

              {this.props.user &&
                <LinkContainer to="workers">
                  <NavItem>Workers</NavItem>
                </LinkContainer>
              }

              {this.props.user &&
                <LinkContainer to="progress">
                  <NavItem>Progress</NavItem>
                </LinkContainer>
              }
            </Nav>

            <Nav navbar pullRight>
              {!this.props.user &&
                <LinkContainer to="signin">
                  <NavItem>Sign In</NavItem>
                </LinkContainer>
              }

              {!this.props.user &&
                <LinkContainer to="signup">
                  <NavItem>Sign Up</NavItem>
                </LinkContainer>
              }

              {this.props.user &&
                <LinkContainer to="profile">
                  <NavItem>{this.props.user.email}</NavItem>
                </LinkContainer>
              }

              {this.props.user &&
                <NavItem
                  onClick={ () => {
                    this.props.signOut().then(() => this.props.pushState('/'));
                  }}
                >
                  Sign Out
                </NavItem>
              }
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

