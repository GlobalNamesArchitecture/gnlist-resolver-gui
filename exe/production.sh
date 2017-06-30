#!/bin/bash

sleep 3

while [[ "$(pg_isready -h ${RACKAPP_DB_HOST} -U ${RACKAPP_DB_USERNAME})" =~ "no response" ]]; do
  echo "Waiting for postgresql to start..."
  sleep 1
done

cd /app/assets/elm && elm-make Main.elm --output ../../public/js/Main.js --yes
cd /app
bundle exec rake db:migrate RACK_ENV=production
rackup -o 0.0.0.0
