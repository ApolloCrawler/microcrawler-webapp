export default class NullStorage {
  getItem(/* key */) {
    return null;
  }

  setItem(/* key, value */) {
  }
}
