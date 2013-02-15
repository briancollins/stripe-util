ENV['BUNDLE_GEMFILE'] ||= File.expand_path(
  File.join(File.dirname(__FILE__), '..', 'Gemfile')
)
require 'bundler'
require 'bundler/setup'
Bundler.require(:default)

require File.join(File.dirname(__FILE__), 'stripe-util', 'stripe-util')

