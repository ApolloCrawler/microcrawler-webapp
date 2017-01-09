import React, {Component, PropTypes} from 'react';

import Helmet from 'react-helmet';

export default class Progress extends Component {
  static propTypes = {
    workers: PropTypes.object
  };

  render() {
    return (
      <div className="container">
        <Helmet title="Progress" />
      </div>
    );
  }
}
