import { combineReducers } from 'redux';
import { routerReducer } from 'react-router-redux';
import { reducer as reduxAsyncConnect } from 'redux-connect';

import workers from './workers';

export default combineReducers({
  routing: routerReducer,
  reduxAsyncConnect,

  // Real reducer modules
  workers
});
