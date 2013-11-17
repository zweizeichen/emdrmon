/*
 * emdrmon main script
 */

// Load global configuration
var config = require('./config');

// Load EMDR listener code
var listener = require('./lib');

// General purpose stuff
var colors = require('colors');


/*
 * Initialize fnordmetric client
 */

var listeners = [];

// Connect to the relays specified in the config file
for (var relay in config.relays) {

  process.stdout.write('Connecting to ' + config.relays[relay].underline + ':');

  // Connect to the relay.
  if (config.relays[relay] == config.reference){
    listeners += new listener(config.relays[relay], true);
  } else {
    listeners += new listener(config.relays[relay], false);
  }

  console.log(' OK!'.green);
}