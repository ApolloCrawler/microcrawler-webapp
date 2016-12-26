import {generateReduxSymbol} from '../helpers/redux';

const ENQUEUE_URL = generateReduxSymbol('crawlers/ENQUEUE_URL');

const GET_LIST = generateReduxSymbol('crawlers/GET_LIST');
const GET_LIST_SUCCESS = generateReduxSymbol('crawlers/GET_LIST_SUCCESS');
const GET_LIST_FAIL = generateReduxSymbol('crawlers/GET_LIST_FAIL');

const initialState = {
  ts: new Date(),
  crawlers: []
};

export default function reducer(oldState = initialState, action = {}) {
  const state = oldState; // convertState(oldState);

  switch (action.type) {
    case GET_LIST_SUCCESS: {
      return {
        ...state,
        crawlers: action.result
      };
    }

    default:
      return state;
  }
}

export function enqueueUrl(url, crawler) {
  return {
    type: ENQUEUE_URL,
    url,
    crawler
  };
}

export function crawlersGetList() {
  return {
    types: [GET_LIST, GET_LIST_SUCCESS, GET_LIST_FAIL],
    promise: (client) => client.get('/api/v1/crawlers')
  };
}
