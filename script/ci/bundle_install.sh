#! /usr/bin/env sh

export PATH="/usr/local/bin:/usr/bin:$PATH"
export QMAKE=/usr/local/lib/qt5/bin/qmake
export SPEC=freebsd-clang   # FreeBSD should use clang, not g++
export CAPYBARA_WEBKIT_INCLUDE_PATH=/usr/local/include
export CAPYBARA_WEBKIT_LIBS="-L/usr/local/lib/"
bundle check || bundle install --deployment --without development
