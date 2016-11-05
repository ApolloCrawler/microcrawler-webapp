import cookies from 'js-cookie';

import {generateReduxSymbol} from '../helpers/redux';

const AUTH_SET_PROPERTY = generateReduxSymbol('auth/AUTH_SET_PROPERTY');

const GET_USER = generateReduxSymbol('auth/GET_USER');
const GET_USER_SUCCESS = generateReduxSymbol('auth/GET_USER_SUCCESS');
const GET_USER_FAIL = generateReduxSymbol('auth/GET_USER_FAIL');

const RENEW_WORKER_JWT = generateReduxSymbol('auth/RENEW_WORKER_JWT');
const RENEW_WORKER_JWT_SUCCESS = generateReduxSymbol('auth/RENEW_WORKER_JWT_SUCCESS');
const RENEW_WORKER_JWT_FAIL = generateReduxSymbol('auth/RENEW_WORKER_JWT_FAIL');

const SIGN_IN = generateReduxSymbol('auth/SIGN_IN');
const SIGN_IN_SUCCESS = generateReduxSymbol('auth/SIGN_IN_SUCCESS');
const SIGN_IN_FAIL = generateReduxSymbol('auth/SIGN_IN_FAIL');

const SIGN_OUT = generateReduxSymbol('auth/SIGN_OUT');
const SIGN_OUT_SUCCESS = generateReduxSymbol('auth/SIGN_OUT_SUCCESS');
const SIGN_OUT_FAIL = generateReduxSymbol('auth/SIGN_OUT_FAIL');

const SIGN_UP = generateReduxSymbol('auth/SIGN_UP');
const SIGN_UP_SUCCESS = generateReduxSymbol('auth/SIGN_UP_SUCCESS');
const SIGN_UP_FAIL = generateReduxSymbol('auth/SIGN_UP_FAIL');

const initialState = {
  payload: {},
  user: null
};

export default function reducer(state = initialState, action = {}) {
  switch (action.type) {
    case AUTH_SET_PROPERTY: {
      const payload = state.payload;
      payload[action.name] = action.value;
      return {
        payload,
        ...state
      };
    }

    case GET_USER_SUCCESS: {
      return {
        ...state,
        user: action.result.user
      };
    }

    case GET_USER_FAIL: {
      return {
        ...state,
        user: null
      };
    }

    case RENEW_WORKER_JWT_SUCCESS: {
      return {
        ...state,
        user: action.result.user
      };
    }

    case SIGN_IN_SUCCESS: {
      const authorization = action.response.headers.authorization;
      window.client.headers.authorization = authorization;
      cookies.set('authorization', authorization);
      return {
        ...state,
        user: action.result.user
      };
    }

    case SIGN_IN_FAIL: {
      delete window.client.headers.authorization;
      cookies.remove('authorization');
      return {
        ...state,
        user: null
      };
    }

    case SIGN_OUT_SUCCESS: {
      delete window.client.headers.authorization;
      cookies.remove('authorization');
      return {
        ...state,
        user: null
      };
    }

    default:
      return state;
  }
}

export function getUser() {
  return {
    types: [GET_USER, GET_USER_SUCCESS, GET_USER_FAIL],
    promise: (client) => client.get('/api/v1/auth/user')
  };
}

export function signIn(email, password) {
  const data = {
    email,
    password
  };

  return {
    types: [SIGN_IN, SIGN_IN_SUCCESS, SIGN_IN_FAIL],
    promise: (client) => client.post('/api/v1/auth/signin', { data })
  };
}


export function signOut() {
  return {
    types: [SIGN_OUT, SIGN_OUT_SUCCESS, SIGN_OUT_FAIL],
    promise: (client) => client.post('/api/v1/auth/signout')
  };
}

export function signUp(email, password) {
  const data = {
    email,
    password
  };

  return {
    types: [SIGN_UP, SIGN_UP_SUCCESS, SIGN_UP_FAIL],
    promise: (client) => client.post('/api/v1/auth/signup', { data })
  };
}

export function setProperty(name, value) {
  return {
    type: AUTH_SET_PROPERTY,
    name,
    value
  };
}

export function renewWorkerJWT() {
  return {
    types: [RENEW_WORKER_JWT, RENEW_WORKER_JWT_SUCCESS, RENEW_WORKER_JWT_FAIL],
    promise: (client) => client.post('/api/v1/auth/renew_worker_jwt')
  };
}
