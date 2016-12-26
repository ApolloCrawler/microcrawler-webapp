import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';
import { reducer as reduxAsyncConnect } from 'redux-connect';

import auth from './auth';
import clients from './clients';
import crawlers from './crawlers';
import socket from './socket';
import workers from './workers';

export default combineReducers({
  routing: routerReducer,
  reduxAsyncConnect,

  // Real reducer modules
  auth,
  clients,
  crawlers,
  socket,
  workers
});
