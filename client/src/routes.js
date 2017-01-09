import React from 'react';
import {IndexRoute, Route} from 'react-router';
// import { isLoaded as isAuthLoaded, load as loadAuth } from 'redux/modules/auth';

import App from './containers/App';
import Clients from './containers/Clients';
import Crawlers from './containers/Crawlers';
import Intro from './containers/Intro';
import NotFound from './containers/NotFound';
import Profile from './containers/Profile';
import Progress from './containers/Progress';
import SignIn from './containers/SignIn';
import SignUp from './containers/SignUp';
import Workers from './containers/Workers';

export default (/* store */) => {
  // const requireLogin = (nextState, replace, cb) => {
  //   function checkAuth() {
  //     const { auth: { user }} = store.getState();
  //     if (!user) {
  //       // oops, not logged in, so can't be here!
  //       replace('/');
  //     }
  //     cb();
  //   }
  //
  //   if (!isAuthLoaded(store.getState())) {
  //     store.dispatch(loadAuth()).then(checkAuth);
  //   } else {
  //     checkAuth();
  //   }
  // };

  /**
   * Please keep routes in alphabetical order
   */
  return (
    <Route path="/" component={App}>
      <IndexRoute component={Intro}/>

      <Route path="clients" component={Clients}/>
      <Route path="crawlers" component={Crawlers}/>
      <Route path="intro" component={Intro}/>
      <Route path="progress" component={Progress}/>
      <Route path="profile" component={Profile}/>
      <Route path="signin" component={SignIn}/>
      <Route path="signup" component={SignUp}/>
      <Route path="workers" component={Workers}/>

      { /* Catch all route */ }
      <Route path="*" component={NotFound} status={404} />
    </Route>
  );
};
