#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'stripe-util'))
require 'csv'
require 'optparse'
require 'date'

class Statement
  def initialize(from_date = nil, to_date = nil)
    from_date ||= Date.new(
      Date.today.prev_month.year,
      Date.today.prev_month.month,
      1
    )
    to_date ||= from_date.next_month

    @from_date = from_date
    @to_date = to_date
  end

  def transfers
    @transfers ||= Stripe::Util.all_transfers(
    #  :status => 'paid', 
      :date => {
        :gte => @from_date.to_time.to_i,
        :lt  => @to_date.to_time.to_i,
      }
    )
  end

  def total
    transfers.inject(0) { |sum, t| sum + t.amount }
  end

  def gross
    transfers.inject(0) { |sum, t| sum + t.summary.charge_gross }
  end

  def gross_fees
    transfers.inject(0) { |sum, t| sum + t.summary.charge_fees }
  end

  def gross_refunds
    transfers.inject(0) { |sum, t| sum + t.summary.refund_gross }
  end

  def gross_refund_fees
    transfers.inject(0) { |sum, t| sum + t.summary.refund_fees }
  end

  def gross_adjustments
    transfers.inject(0) { |sum, t| sum + t.summary.adjustment_gross }
  end

  def charge_count
    transfers.inject(0) { |sum, t| sum + t.summary.charge_count }
  end

  def refund_count
    transfers.inject(0) { |sum, t| sum + t.summary.refund_count }
  end

  def adjustment_count
    transfers.inject(0) { |sum, t| sum + t.summary.adjustment_count }
  end

  def generate
    puts "Between #{@from_date} and #{@to_date}"
    puts "Stripe sent you #{transfers.count} transfers " + 
    "for #{charge_count} charges, #{refund_count} refunds, " +
    "and #{adjustment_count} adjustments"

    puts "Net transferred: #{Stripe::Util.amount_string(total)}"
    puts "Gross charges: #{Stripe::Util.amount_string(gross)}"
    puts "Gross charge fees: #{Stripe::Util.amount_string(gross_fees)}"
    puts "Gross refunded charges: #{Stripe::Util.amount_string(gross_refunds)}"
    puts "Gross refunded fees: #{Stripe::Util.amount_string(gross_refund_fees)}"
    puts "Gross adjustments: #{Stripe::Util.amount_string(gross_adjustments)}"
  end
end

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
  puts Statement.new(@options[:from], @options[:to]).generate
end

main

