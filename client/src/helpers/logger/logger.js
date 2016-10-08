export default class Logger {
  debug(...args) {
    this.log(...args);
  }

  error(...args) {
    this.log(...args);
  }

  fatal(...args) {
    this.log(...args);
  }

  info(...args) {
    this.log(...args);
  }

  warn(...args) {
    this.log(...args);
  }

  /* eslint-disable class-methods-use-this */
  log(...args) {
    Logger.log(...args);
  }
  /* eslint-disable class-methods-use-this */

  static log(...args) {
    console.log('logger:', ...args);
  }
}
