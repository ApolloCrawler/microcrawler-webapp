import React, {Component, PropTypes} from 'react';

import Helmet from 'react-helmet';

import {connect} from 'react-redux';

@connect(
  (state) => ({
    workerJWT: state.auth.workerJWT
  })
)

export default class Profile extends Component {
  static propTypes = {
    workerJWT: PropTypes.string
  };

  render() {
    const title = 'Profile';
    return (
      <div className="container">
        <Helmet title={title} />

        <div className="jumbotron" style={{marginTop: '50px'}} >
          <h1 className="text-center">{title}</h1>
          <pre>{this.props.workerJWT}</pre>
        </div>
      </div>
    );
  }
}
