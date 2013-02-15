#!/usr/bin/env ruby

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib', 'stripe-util'))
require 'csv'
require 'optparse'

class RefundExporter
  def previous_amount_refunded(event)
    (
      event.data.respond_to?(:previous_attributes) &&
      event.data.previous_attributes.respond_to?(:amount_refunded) &&
      event.data.previous_attributes.amount_refunded
    ) || 0
  end

  def refund_type(event)
    if previous_amount_refunded(event) == 0 && event.data.object.refunded
      :full
    else
      :partial
    end
  end
   
  def refund_amount(event)
    charge = event.data.object
    if refund_type(event) == :partial
      charge.amount_refunded - previous_amount_refunded(event)
    else
      charge.amount
    end
  end
   
  def event_row(event)
    [
      event.data.object.id,
      event.id,
      Time.at(event.created).utc,
      refund_type(event),
      refund_amount(event)
    ]
  end
   
  def generate_csv(events)
    CSV.generate do |csv|
      csv << %w{ charge_id event_id refund_date refund_type refund_amount }
      events.each do |event|
        csv << event_row(event)
      end
    end
  end

  def export
    events = Stripe::Util.all_events(:type => 'charge.refunded')
    generate_csv(events)
  end
end

def main
  @options = {}
  opts = OptionParser.new do |opts|
    opts.banner = "Usage: #{$0} api_key"
    opts.on('-o', '--output [OUTFILE]', String, 'Output file') do |o|
      @options[:file] = o
    end
  end

  opts.parse!

  if ARGV[0].nil?
    puts opts
    exit
  end

  Stripe.api_key = ARGV[0]
  csv = RefundExporter.new.export
  if @options[:file]
    File.open(@options[:file], 'w') do |f|
      f.write(csv)
    end
  else
    puts csv
  end
end

main
