#!/usr/bin/env bash

# This script runs on Macs, tested with macOS Sierra 10.12.5
# This script assumes the homebrew package manager for OSX is already installed
#
# Xcode and command line tools should be updated to latest versions beforehand

read -p "Is xcode installed/updated to latest version? " -n 1 -r
echo
if ! [[ $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

read -p "Are osx command line tools installed/updated to latest version? (command 'xcode-select --install' or use Mac App Store updates tab) " -n 1 -r
echo
if ! [[ $REPLY =~ ^[Yy]$ ]]
then
  exit 1
fi

gem_install_or_update() {
  if gem list "$1" --installed > /dev/null; then
    echo "Updating just $@ if needed"
    gem update "$@"
  else
    echo Installing "$@"
    gem install "$@"
  fi
}

configured_version=`cat .ruby-version`

brew upgrade rbenv ruby-build

if `rbenv versions 2> /dev/null | grep --quiet $configured_version`
then
  echo ruby $configured_version already installed
else
  echo ruby $configured_version not installed. Installing with rbenv
  rbenv install $configured_version
  rbenv rehash
fi

gem_install_or_update "bundler"
gem_install_or_update "overcommit"
gem_install_or_update "foreman"
overcommit --sign

bundle install

npm install
