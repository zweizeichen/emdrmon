#!/usr/bin/env ruby

$: << File.expand_path(File.dirname(__FILE__))

require 'fnordmetric_app'

FnordMetric::Worker.new()
FnordMetric.run
