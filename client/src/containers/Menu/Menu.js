import React, { Component, PropTypes } from 'react';

import { connect } from 'react-redux';
import { push } from 'react-router-redux';

import { IndexLink } from 'react-router';
import { LinkContainer } from 'react-router-bootstrap';

import Nav from 'react-bootstrap/lib/Nav';
import Navbar from 'react-bootstrap/lib/Navbar';
import NavItem from 'react-bootstrap/lib/NavItem';

import config from '../../config';

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
export default class Menu extends Component {
  static propTypes = {
    pushState: PropTypes.func.isRequired,
    signOut: PropTypes.func,

    user: PropTypes.object,
  };

  render() {
    const styles = require('./Menu.scss');

    return (
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

            {this.props.user &&
            <LinkContainer to="admin">
              <NavItem>Admin</NavItem>
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
    );
  }
}
