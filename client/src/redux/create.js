import { createStore as _createStore, applyMiddleware, compose } from 'redux';
import { routerMiddleware } from 'react-router-redux';

import createMiddleware from './middleware/clientMiddleware';
import reducer from './modules/reducer';

export default function createStore(history, client, data) {
  // Sync dispatched route actions to the history
  const reduxRouterMiddleware = routerMiddleware(history);

  const middleware = [createMiddleware(client), reduxRouterMiddleware];

  let finalCreateStore;
  // FIXME: Use global variable
  if (true /* __DEVELOPMENT__ && __CLIENT__ && __DEVTOOLS__ */) {
    const { persistState } = require('redux-devtools');
    const DevTools = require('../containers/DevTools/DevTools');

    finalCreateStore = compose(
      applyMiddleware(...middleware),
      window.devToolsExtension ? window.devToolsExtension() : DevTools.instrument(),
      persistState(window.location.href.match(/[?&]debug_session=([^&]+)\b/))
    )(_createStore);
  } else {
    finalCreateStore = applyMiddleware(...middleware)(_createStore);
  }

  // const reducer = require('./modules/reducer');

  const store = finalCreateStore(reducer, data);

  // FIXME: Use global variable
  if (true /* __DEVELOPMENT__ */ && module.hot) {
    module.hot.accept('./modules/reducer', () => {
      store.replaceReducer(require('./modules/reducer'));
    });
  }

  return store;
}
