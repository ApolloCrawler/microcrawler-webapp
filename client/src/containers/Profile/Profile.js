import React, {Component, PropTypes} from 'react';
import Helmet from 'react-helmet';
import {connect} from 'react-redux';
import {Button} from 'react-bootstrap';
import * as authActions from '../../redux/modules/auth';

@connect(
  (state) => ({
    user: state.auth.user
  }),
  {
    ...authActions
  }
)

export default class Profile extends Component {
  static propTypes = {
    user: PropTypes.object,
    renewWorkerJWT: PropTypes.func
  };

  render() {
    const title = 'Profile';
    return (
      <div className="container">
        <Helmet title={title} />

        <div className="jumbotron" style={{marginTop: '50px'}} >
          <h1 className="text-center">{title}</h1>
          <pre>{this.props.user && this.props.user.workerJWT}</pre>
          <Button
            bsStyle="primary"
            type="button"
            onClick={
              () => {
                this.props.renewWorkerJWT();
              }
            }
          >Renew </Button>
        </div>
      </div>
    );
  }
}
