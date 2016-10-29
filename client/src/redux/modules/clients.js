// import Immutable from 'immutable';
// import merge from 'node.extend';
// import R from 'ramda';
//
// import {generateReduxSymbol} from '../helpers/redux';
//
// const WORKERS_ADD = generateReduxSymbol('workers/WORKERS_ADD');
// const WORKERS_CLEAN = generateReduxSymbol('workers/WORKERS_CLEAN');
// const WORKERS_REMOVE = generateReduxSymbol('workers/WORKERS_REMOVE');
// const WORKERS_SET = generateReduxSymbol('workers/WORKERS_SET');
// const WORKERS_UPDATE = generateReduxSymbol('workers/WORKERS_UPDATE');

const initialState = {
  ts: new Date(),
  clients: []
};

export default function reducer(oldState = initialState, action = {}) {
  const state = oldState; // convertState(oldState);

  switch (action.type) {
    default:
      return state;
  }
}
