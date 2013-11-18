# emdrmon - a realtime EMDR monitor

## Overview

Emdrmon is a realtime network monitoring web application for the EVE Market Data Network (EMDR) based on fnordmetrics and NodeJS.

## Installing and running emdrmon

* Install a recent version of Ruby, NodeJS, Redis and ZeroMQ
* Start your Redis server
* `git clone` this repository
* Run `npm install` and `bundle install` from inside your cloned repo
* Execute `rackup` in order to start the web interface
* Execute `ruby worker.rb` in order to spin up a fnordmetric worker
* Execute `node app` to start the stat collector which will connect to the various relays
* The web application will listen on port `4242` now

It is recommended to run this setup behind an `nginx` or similar reverse proxy and to control the processes via e.g. `supervisord`. Note that this app makes heavy use of websockets, which are only supported by newer versions of nginx.

## Known Issues

Currently there are multiple layout issues related to fnordmetrics which can be resolved by manually editing the CSS in the gem's directory. Also you might experience rather high memory usage by Redis. Try to adjust `:event_data_ttl` at the bottom of `fnordmetric_app.rb` in that case.

Also you won't be able to connect to EMDR's primary master announcer even though it shows up as properly connected. Please adjust `config.js` accordingly.