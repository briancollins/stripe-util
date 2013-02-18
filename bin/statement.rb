#!/usr/bin/env ruby

require 'bundler/setup'
require 'optparse'
require 'date'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib')))
require 'stripe-util'

def main
  @options = {}
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} api_key"

    opts.on('-f', '--from [yyyy-mm-dd]', String, 'From date') do |d|
      @options[:from] = Date.parse(d)
    end

    opts.on('-t', '--to [yyyy-mm-dd]', String, 
            'To date (from date is required if you pass this)') do |d|
      if @options[:from].nil?
        puts opts
        exit
      end

      @options[:to] = Date.parse(d)
    end
  end

  opts.parse!

  if ARGV[0].nil?
    puts opts
    exit
  end

  Stripe.api_key = ARGV[0]
  statement = Stripe::Util::Statement.new(@options[:from], @options[:to])
  puts "Between #{statement.from_date} and #{statement.to_date}"
  puts "Stripe sent you #{statement.transfers.count} transfers " + 
  "for #{statement.charge_count} charges, #{statement.refund_count} refunds, " +
  "and #{statement.adjustment_count} adjustments"

  puts "Net transferred: #{Stripe::Util::Numeric.pretty_amount(statement.total)}"
  puts "Gross charges: #{Stripe::Util::Numeric.pretty_amount(statement.gross)}"
  puts "Gross charge fees: #{Stripe::Util::Numeric.pretty_amount(statement.gross_fees)}"
  puts "Gross refunded charges: #{Stripe::Util::Numeric.pretty_amount(statement.gross_refunds)}"
  puts "Gross refund fees: #{Stripe::Util::Numeric.pretty_amount(statement.gross_refund_fees)}"
  puts "Gross adjustments: #{Stripe::Util::Numeric.pretty_amount(statement.gross_adjustments)}"
end

main

