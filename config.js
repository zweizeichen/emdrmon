var config = {};

// EMDR relays emdrmon will connect to
config.relays = ['tcp://master.eve-emdr.com:8050',
                 'tcp://secondary.eve-emdr.com:8050',
                 'tcp://relay-us-west-1.eve-emdr.com:8050',
                 'tcp://relay-us-central-1.eve-emdr.com:8050',
                 'tcp://relay-us-east-1.eve-emdr.com:8050',
                 'tcp://relay-ca-east-1.eve-emdr.com:8050',
                 'tcp://relay-eu-germany-1.eve-emdr.com:8050',
                 'tcp://relay-eu-france-2.eve-emdr.com:8050',
                 'tcp://relay-eu-denmark-1.eve-emdr.com:8050'];

// EMDR Reference relay
config.reference = 'tcp://master.eve-emdr.com:8050';

module.exports = config;