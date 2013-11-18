module Enumerable
  def last
    to_a.last
  end
end

require "fnordmetric"

FnordMetric.namespace :emdrmon do

  #
  # Reference Gauges
  #

  gauge :reference_messages_per_minute,
    :three_dimensional => true,
    :tick => 5.minutes.to_i,
    :title => "Order Messages per minute"

  gauge :reference_orders_per_minute,
    :tick => 1.minute.to_i,
    :title => "Orders per minute"

  gauge :reference_history_datapoints_per_minute,
    :tick => 1.minute.to_i,
    :title => "History datapoints per minute"

  gauge :reference_top_clients_per_hour,
    :three_dimensional => true,
    :tick => 1.hour.to_i,
    :title => "Top clients used to upload data"

  toplist_gauge :reference_modern_top_clients_per_minute,
    :title => "Top clients",
    :key_nouns => ['Client', 'Clients'],
    :resolution => 1.minute

  toplist_gauge :reference_modern_top_uploaders_per_minute,
    :title => "Top uploaders",
    :key_nouns => ['Hash', 'Hashes'],
    :resolution => 1.minute

  toplist_gauge :reference_modern_top_regions_per_minute,
    :title => "Top regions",
    :key_nouns => ['Region', 'Regions'],
    :resolution => 1.minute

  toplist_gauge :reference_modern_top_types_per_minute,
    :title => "Top types",
    :key_nouns => ['Type', 'Types'],
    :resolution => 1.minute

  #
  # Relay-Specific Gauges
  #

  # us_west_1

  gauge :us_west_1_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "US West 1"

  gauge :us_west_1_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "US West 1"

  # us_central_1

  gauge :us_central_1_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "US Central 1"

  gauge :us_central_1_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "US Central 1"

  # us_east_1

  gauge :us_east_1_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "US East 1"

  gauge :us_east_1_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "US East 1"

  # ca_east_1

  gauge :ca_east_1_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "CA East 1"

  gauge :ca_east_1_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "CA East 1"

  # eu_germany_1

  gauge :eu_germany_1_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "EU Germany 1"

  gauge :eu_germany_1_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "EU Germany 1"

  # eu_france_2

  gauge :eu_france_2_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "EU France 2"

  gauge :eu_france_2_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "EU France 2"

  # eu_denmark_1

  gauge :eu_denmark_1_messages_per_minute,
    :tick => 1.minute.to_i,
    :title => "EU Denmark 1"

  gauge :eu_denmark_1_messages_per_hour,
    :tick => 1.hour.to_i,
    :title => "EU Denmark 1"

  #
  # Reference Events
  #

  event :message_reference do

    # Increment message type counters
    incr_field :reference_messages_per_minute, data[:message_type], 1

    # Increment datapoint gauges accordingly
    if data[:message_type] == "orders"
      incr :reference_orders_per_minute, data[:number]
    else
      incr :reference_history_datapoints_per_minute, data[:number]
    end

    # Update client stats - there are two counters, because the toplist widget does not work with non-classic gauges
    incr_field :reference_top_clients_per_hour, data[:client], 1
    observe :reference_modern_top_clients_per_minute, data[:client]

    # Count IP hash
    observe :reference_modern_top_uploaders_per_minute, data[:ip_hash]

    # Push affected types/regions to our gauges
    data[:affected_regions].each do |region|
      observe :reference_modern_top_regions_per_minute, region
    end

    data[:affected_types].each do |type|
      observe :reference_modern_top_types_per_minute, type
    end
  end

  #
  # Relay-specific Events
  #

  #us_west_1

  event :message_us_west_1 do
    incr :us_west_1_messages_per_minute, 1
    incr :us_west_1_messages_per_hour, 1
  end

  #us_central_1

  event :message_us_central_1 do
    incr :us_central_1_messages_per_minute, 1
    incr :us_central_1_messages_per_hour, 1
  end

  #us_east_1

  event :message_us_east_1 do
    incr :us_east_1_messages_per_minute, 1
    incr :us_east_1_messages_per_hour, 1
  end

  #ca_east_1

  event :message_ca_east_1 do
    incr :ca_east_1_messages_per_minute, 1
    incr :ca_east_1_messages_per_hour, 1
  end

  #eu_germany_1

  event :message_eu_germany_1 do
    incr :eu_germany_1_messages_per_minute, 1
    incr :eu_germany_1_messages_per_hour, 1
  end

  #eu_france_2

  event :message_eu_france_2 do
    incr :eu_france_2_messages_per_minute, 1
    incr :eu_france_2_messages_per_hour, 1
  end

  #eu_denmark_1

  event :message_eu_denmark_1 do
    incr :eu_denmark_1_messages_per_minute, 1
    incr :eu_denmark_1_messages_per_hour, 1
  end

  #
  # Dashboard Widgets
  #

  widget 'Network Overview', {
    :title => "Messages per minute",
    :type => :numbers,
    :gauges => [:us_west_1_messages_per_minute,
                :us_central_1_messages_per_minute,
                :us_east_1_messages_per_minute,
                :ca_east_1_messages_per_minute,
                :eu_germany_1_messages_per_minute,
                :eu_france_2_messages_per_minute,
                :eu_denmark_1_messages_per_minute],
    :include_current => true,
    :offsets => [0, 1],
    :autoupdate => 1,
    :width => 100
  }

  widget 'Network Overview', {
    :title => "Message History",
    :gauges => [:us_west_1_messages_per_minute,
                :us_central_1_messages_per_minute,
                :us_east_1_messages_per_minute,
                :ca_east_1_messages_per_minute,
                :eu_germany_1_messages_per_minute,
                :eu_france_2_messages_per_minute,
                :eu_denmark_1_messages_per_minute],
    :type => :timeline,
    :width => 70,
    :autoupdate => 3
  }

  widget 'Network Overview', {
    :title => "Message Types",
    :gauges => :reference_messages_per_minute,
    :type => :toplist,
    :width => 30,
    :autoupdate => 1
  }

  widget 'Network Overview', {
    :title => "Datapoint throughput per minute",
    :gauges => [:reference_orders_per_minute,
                :reference_history_datapoints_per_minute],
    :type => :timeline,
    :width => 70,
    :autoupdate => 3
  }

  widget 'Network Overview', {
    :title => "Top EMDR Clients",
    :gauges => :reference_top_clients_per_hour,
    :type => :toplist,
    :width => 30,
    :autoupdate => 1
  }

end

FnordMetric.options = {
  :enable_active_users => false,
  :event_data_ttl => 2.hours
}