import React, {Component, PropTypes} from 'react';

import {connect} from 'react-redux';
import { push } from 'react-router-redux';

import {
  Button,
  Checkbox,
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
    payload: state.auth.payload
  }),
  {
    pushState: push,
    ...authActions
  }
)
export default class SignIn extends Component {
  static propTypes = {
    payload: PropTypes.object,
    pushState: PropTypes.func.isRequired,
    setProperty: PropTypes.func,
    signIn: PropTypes.func
  };

  render() {
    const title = 'Sign In';
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

            {false &&
              <FormGroup>
                <Col smOffset={2} sm={10}>
                  <Checkbox>Remember me</Checkbox>
                </Col>
              </FormGroup>
            }
            <FormGroup>
              <Col smOffset={2} sm={10}>
                <Button
                  bsStyle="primary"
                  type="submit"
                  onClick={
                    (e) => {
                      e.preventDefault();
                      this.props.signIn(this.props.payload.email, this.props.payload.password).then(
                        () => {
                          this.props.pushState('/');
                        },
                        (error) => {
                          console.log(error);
                        }
                      );
                    }}
                >
                  Sign In
                </Button>
              </Col>
            </FormGroup>
          </Form>
        </Jumbotron>
      </div>
    );
  }
}
