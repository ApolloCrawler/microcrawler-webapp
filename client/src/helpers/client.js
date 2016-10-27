import cookies from 'js-cookie';
import superagent from 'superagent';

export const methods = [
  'get',
  'post',
  'put',
  'patch',
  'del'
];

function formatUrl(path) {
  return path;
}

class Client {
  constructor(/* req */) {
    methods.forEach((method) => {
      this.wrapMethod(method);
    });

    this.headers = {};

    const authorization = cookies.get('authorization');
    if (authorization) {
      this.headers.authorization = authorization;
    }
  }

  static addHeaders(request, headers) {
    if (headers) {
      const keys = Object.keys(headers);
      for (let i = 0; i < keys.length; i += 1) {
        const key = keys[i];
        const value = headers[key];
        request.set(key, value);
      }
    }

    return request;
  }

  wrapMethod(method) {
    const func = (path, {params, data} = {}) => new Promise((resolve, reject) => {
      let request = superagent[method](formatUrl(path));

      if (params) {
        request.query(params);
      }

      if (data) {
        request.send(data);
      }

      const headers = (params && params.headers) || {};
      request = Client.addHeaders(request, headers);
      request = Client.addHeaders(request, this.headers || {});

      request.end((err, res = {}) => {
        const {body, text} = res;
        return err ? reject({body: body || err, response: res}) : resolve({body: body || text, response: res});
      });
    });

    this[method] = func;
  }
}

export default Client;
