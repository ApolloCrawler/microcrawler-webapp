import React from 'react';
import ReactDOM from 'react-dom';

import App from './containers/App';

import logger from './helpers/logger';

ReactDOM.render(<App />, document.getElementById('app'));

logger.info('Single Page Application created');
