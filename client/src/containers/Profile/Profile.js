import React, {Component} from 'react';

import Helmet from 'react-helmet';

export default class Profile extends Component {
  render() {
    const title = 'Profile';
    return (
      <div className="container">
        <Helmet title={title} />

        <div className="jumbotron" style={{marginTop: '50px'}} >
          <h1 className="text-center">{title}</h1>
        </div>
      </div>
    );
  }
}
