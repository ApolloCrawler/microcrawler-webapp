import React, {Component, PropTypes} from 'react';

import {connect} from 'react-redux';
import { push } from 'react-router-redux';

import {
  Button,
  Col,
  ControlLabel,
  Form,
  FormControl,
  FormGroup,
  Jumbotron
} from 'react-bootstrap';

import Helmet from 'react-helmet';

import * as authActions from '../../redux/modules/auth';

@connect(
  (state) => ({
    payload: state.auth.payload,
  }),
  {
    pushState: push,
    ...authActions
  }
)
export default class SignUp extends Component {
  static propTypes = {
    payload: PropTypes.object,
    pushState: PropTypes.func.isRequired,
    setProperty: PropTypes.func,
    signUp: PropTypes.func
  };

  render() {
    const title = 'Sign Up';
    return (
      <div className="container">
        <Helmet title={title} />

        <Jumbotron style={{marginTop: '50px'}}>
          <h1 className="text-center">{title}</h1>
          <Form horizontal>
            <FormGroup controlId="formHorizontalEmail">
              <Col componentClass={ControlLabel} sm={2}>
                Email
              </Col>
              <Col sm={10}>
                <FormControl
                  type="email"
                  placeholder="Email"
                  // value={this.props.payload.email}
                  onChange={(event) => this.props.setProperty('email', event.target.value)}
                />
              </Col>
            </FormGroup>

            <FormGroup controlId="formHorizontalPassword">
              <Col componentClass={ControlLabel} sm={2}>
                Password
              </Col>
              <Col sm={10}>
                <FormControl
                  type="password"
                  placeholder="Password"
                  // value={this.props.payload.password}
                  onChange={(event) => this.props.setProperty('password', event.target.value)}
                />
              </Col>
            </FormGroup>

            <FormGroup>
              <Col smOffset={2} sm={10}>
                <Button
                  bsStyle="primary"
                  type="submit"
                  onClick={
                    (e) => {
                      e.preventDefault();
                      this.props.signUp(this.props.payload.email, this.props.payload.password).then(
                        () => {
                          this.props.pushState('/signin');
                        },
                        (error) => {
                          // TODO: Add better handling!
                          console.log(error);
                        }
                      );
                    }
                  }
                >
                  Sign Up
                </Button>
              </Col>
            </FormGroup>
          </Form>
        </Jumbotron>
      </div>
    );
  }
}
