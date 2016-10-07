import React, { PureComponent } from 'react';

import { IndexLink } from 'react-router';
import { LinkContainer } from 'react-router-bootstrap';

import Nav from 'react-bootstrap/lib/Nav';
import Navbar from 'react-bootstrap/lib/Navbar';
import NavItem from 'react-bootstrap/lib/NavItem';

export default class App extends PureComponent {
  render() {
    const styles = require('./App.scss');

    return (
      <div className={styles.app}>
        <Navbar fixedTop>
          <Navbar.Header>
            <Navbar.Brand>
              <IndexLink to="/" activeStyle={{ color: '#33e0ff' }}>
                <div className={styles.brand}/>
                <span>Microcrawler</span>
              </IndexLink>
            </Navbar.Brand>
            <Navbar.Toggle/>
          </Navbar.Header>

          <Navbar.Collapse>
            <Nav navbar>
              <LinkContainer to="/">
                <NavItem>Home</NavItem>
              </LinkContainer>
            </Nav>
          </Navbar.Collapse>
        </Navbar>
      </div>
    );
  }
}
