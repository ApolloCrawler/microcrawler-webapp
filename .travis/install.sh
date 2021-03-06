#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
  brew update # get list of latest packages
  brew install libcouchbase erlang elixir
else
  # Only needed during first-time setup:
  wget http://packages.couchbase.com/releases/couchbase-release/couchbase-release-1.0-2-amd64.deb
  sudo dpkg -i couchbase-release-1.0-2-amd64.deb

  # Will install or upgrade packages
  sudo apt-get update
  sudo apt-get install libcouchbase-dev libcouchbase2-bin build-essential libstdc++6 libc6 g++ llvm clang runit wget python-httplib2
fi