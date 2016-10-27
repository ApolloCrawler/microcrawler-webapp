import NullStorage from './NullStorage';

export default class Storage {
  constructor() {
    if (typeof(Storage) !== 'undefined') {
      this._storage = localStorage;
    } else {
      this._storage = new NullStorage();
    }
  }

  get storage() {
    return this._storage;
  }

  getItem(key) {
    return this.storage.getItem(key);
  }

  setItem(key, value) {
    try {
      return this.storage.setItem(key, value);
    } catch (e) {
      console.log('Storage.setItem() - Unable to store.', key, e);
    }
  }
}
