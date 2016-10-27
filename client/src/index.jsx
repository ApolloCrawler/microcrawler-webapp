import React from 'react';
import ReactDOM from 'react-dom';

import { AppContainer as HotEnabler } from 'react-hot-loader';
import { ReduxAsyncConnect } from 'redux-connect';
import { Provider } from 'react-redux';
import { Router, browserHistory } from 'react-router';
import { syncHistoryWithStore } from 'react-router-redux';
import withScroll from 'scroll-behavior';

import logger from './helpers/logger';
import createStore from './redux/create';
import getRoutes from './routes';

import { getUser } from './redux/modules/auth';

import Client from './helpers/client';

const client = window.client = new Client();

const myBrowserHistory = withScroll(browserHistory);
const dest = document.getElementById('app');
const store = createStore(myBrowserHistory, client, window.__data); // eslint-disable-line no-underscore-dangle
const history = syncHistoryWithStore(myBrowserHistory, store);

store.dispatch(getUser());

const renderRouter = (props) => <ReduxAsyncConnect {...props} helpers={{ client }} filter={item => !item.deferred} />;
const render = routes => {
  ReactDOM.render(
    <HotEnabler>
      <Provider store={store} key="provider">
        <Router history={history} render={renderRouter}>
          {routes}
        </Router>
      </Provider>
    </HotEnabler>,
    dest
  );
};

render(getRoutes(store));

// FIXME: Use global variable
if (true /* __DEVTOOLS__ */ && !window.devToolsExtension) {
  const devToolsDest = document.createElement('div');
  window.document.body.insertBefore(devToolsDest, null);
  const DevTools = require('./containers/DevTools/DevTools');

  ReactDOM.render(
    <Provider store={store} key="provider">
      <DevTools />
    </Provider>,
    devToolsDest
  );
}

logger.info('Single Page Application created.');
