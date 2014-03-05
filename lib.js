// Message handling
var zlib = require('zlib');
var zmq = require('zmq');

// Static assets
var regions = require('./regions.json');
var types = require('./types.json');

// Fnordmetric client
var Fnoed = require('fnoed');
var fnord = new Fnoed();

// Returns a beautified verseion of the relay's URL
function beautifyRelayName(relayURL){
  return relayURL.replace('tcp://', '').replace('relay-', '').replace('.eve-emdr.com:8050', '').replace(/-/g, '_');
}


/*
 * This class listens for messages on EMDR and submits stats to fnordmetric
 */

var EMDRStatsListener = function(relay, isReference) {
  this.relay = relay;
  this.isReference = isReference;

  // Socket
  this.socket = zmq.socket('sub');
  this.socket.subscribe('');

  // Error handling for ZMQ
  this.socket.on('error', function(error) {
    console.log('ERROR: ' + error);
  });

  // Connect and register event handlers
  this.socket.connect(this.relay);
  this.socket.on('message', this.handleMessage.bind(this));

  // Store timestamp of last message received
  this.lastMessage = new Date().getTime();

  // If we reconnect and still don't receive any messages, 
  // increment pause between attempts gradually up to 30 minutes
  this.reconnectAttempts = 0;
  this.currentIntervalInSeconds = 1;
  this.lastAttempt = new Date().getTime();

  // Schedule connection watchdog
  setInterval(this.watchConnection.bind(this), 1000);
};

EMDRStatsListener.prototype.watchConnection = function() {

  var now = new Date();

  // Automatically try to reconnect if there were no messages for 10 seconds
  if((now.getTime() - this.lastMessage) > 10000) {

    // Reconnect if necessary
    if((now.getTime() - this.lastAttempt) > (this.currentIntervalInSeconds * 1000)){

      // Construct time string
      time = '[' + ('0' + now.getHours()).slice(-2)   + ':' + 
                   ('0' + now.getMinutes()).slice(-2) + ':' + 
                   ('0' + now.getSeconds()).slice(-2) + '] ';

      // Reconnect
      console.log(time + 'Reconnecting to ' + this.relay + '... ');
      this.socket.connect(this.relay);

      // Increase counters and reset lastAttempt
      this.reconnectAttempts++;
      this.lastAttempt = now.getTime();

      // Calculate Interval
      this.currentIntervalInSeconds = Math.pow((this.reconnectAttempts+2), 2);

      // Cap at 30 minutes
      if(this.currentIntervalInSeconds > 1800){
        this.currentIntervalInSeconds = 1800;
      }
    }
  }
};

EMDRStatsListener.prototype.handleMessage = function(message) {
  // Reset reconnect attempts, now that we've got a message
  this.reconnectAttempts = 0;

  // Update lastMessage
  this.lastMessage = new Date().getTime();

  // Sends regular stats to fnordmetric
  fnord.send({_type: 'message_' + beautifyRelayName(this.relay)}, true);

  // Only perform further analysis if relay is the reference relay
  if (this.isReference) {
    zlib.inflate(message, function(error, marketData) {

      var number = 0;
      var affectedTypes = [];
      var affectedRegions = [];

      // Parse the JSON data
      marketData = JSON.parse(marketData);

      if (marketData.resultType == 'orders'){
        // Count all orders in all rowsets and collect types (it is intended that there can be multiple types at once)
        for(var orderRowset in marketData.rowsets){
          number = number + marketData.rowsets[orderRowset].rows.length;
          affectedTypes.push(types[marketData.rowsets[orderRowset].typeID]);
          affectedRegions.push(regions[marketData.rowsets[orderRowset].regionID]);
        }
      } else {
        // Count all historyDatapoints in all rowsets and collect regions (it is intended that there can be multiple regions at once)
        for(var historyRowset in marketData.rowsets){
          number = number + marketData.rowsets[historyRowset].rows.length;
          affectedTypes.push(types[marketData.rowsets[historyRowset].typeID]);
          affectedRegions.push(regions[marketData.rowsets[historyRowset].regionID]);
        }
      }

      // Get formatted name and shorten EveMon's MarketUnifiedUploader
      var emdrClientName = marketData.generator.name.replace("MarketUnifiedUploader", "MMU") + " " + marketData.generator.version;

      // Get uploader's IP hash
      var hash = "anonymous";
      for (var index in marketData.uploadKeys){
        if (marketData.uploadKeys[index].name == 'EMDR') hash = marketData.uploadKeys[index].key + ' / ' + emdrClientName;
      }

      // Send stats to fnordmetric
      fnord.send({_type: 'message_reference',
                  message_type: marketData.resultType,
                  number: number,
                  ip_hash: hash,
                  client: emdrClientName,
                  affected_regions: affectedRegions,
                  affected_types: affectedTypes},
                  true);

    }.bind(this));
  }
};

module.exports = EMDRStatsListener;