#! /usr/bin/env bash

docker-compose stop rails
docker-compose run --service-ports rails bundle exec rails s -b0.0.0.0