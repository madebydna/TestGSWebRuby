#!/usr/bin/env bash

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
