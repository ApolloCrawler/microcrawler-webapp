// import Immutable from 'immutable';
import R from 'ramda';

import {generateReduxSymbol} from '../helpers/redux';

const WORKERS_ADD = generateReduxSymbol('workers/WORKERS_ADD');
const WORKERS_REMOVE = generateReduxSymbol('workers/WORKERS_REMOVE');
const WORKERS_SET = generateReduxSymbol('workers/WORKERS_SET');
const WORKERS_UPDATE = generateReduxSymbol('workers/WORKERS_UPDATE');

/**
 * Converts state to immutable version if needed
 * @param state State to by possibly converted
 * @returns {*}
 */
// function convertState(state) {
//   if (state instanceof Immutable.Map) {
//     return state;
//   }
//
//   return Immutable.fromJS(state);
// }

const initialState = {
  ts: new Date(),
  workers: []
};

export default function reducer(oldState = initialState, action = {}) {
  const state = oldState; // convertState(oldState);

  switch (action.type) {
    case WORKERS_ADD:
      return {
        ...state
      };

    case WORKERS_REMOVE: {
      const workers = R.reject((w => (w.join.uuid === action.worker.join.uuid)), state.workers);

      return {
        ...state,
        ts: new Date(),
        workers: JSON.parse(JSON.stringify(workers))
      };
    }

    case WORKERS_SET:
      return {
        ...state
      };

    case WORKERS_UPDATE: {
      const condition = R.pathEq(['join', 'uuid'], action.worker.join.uuid);
      const worker = R.find(condition)(state.workers);

      const workers = state.workers;
      if (worker) {
        worker.join = action.worker.join;
        worker.ping = action.worker.ping;
      } else {
        workers.push(action.worker);
      }

      return {
        ...state,
        ts: new Date(),
        workers: JSON.parse(JSON.stringify(workers))
      };
    }

    default:
      return state;
  }
}

export function workersAdd(worker) {
  return {
    type: WORKERS_ADD,
    worker
  };
}

export function workersRemove(worker) {
  return {
    type: WORKERS_REMOVE,
    worker
  };
}

export function workersSet(workers) {
  return {
    type: WORKERS_SET,
    workers
  };
}

export function workersUpdate(worker) {
  return {
    type: WORKERS_UPDATE,
    worker
  };
}
