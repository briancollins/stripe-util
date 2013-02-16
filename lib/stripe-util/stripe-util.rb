module Stripe
  module Util
    def self.all_objects(klass, args={}, count=50, offset=0)
      rsp = klass.all(args.merge(:count => count, :offset => offset))
      objects = rsp.data

      if count * offset < rsp.count
        objects += all_objects(klass, args, count, offset + 1)
      end

      objects
    end

    class << self
      [Charge, Coupon, Customer, Event, Invoice, 
       InvoiceItem, Plan, Transfer].each do |klass|
        name = klass.name.split('::').last.downcase
        define_method("all_#{name}s") do |args = {}|
          all_objects(klass, args)
        end
      end
    end

    def self.amount_string(amount, currency = '$')
      str = ("#{currency}%d.%02d" % [amount.abs / 100, amount % 100]).
        gsub(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1,")

      if amount < 0
        "-#{str}"
      else
        str
      end
    end
  end
end

