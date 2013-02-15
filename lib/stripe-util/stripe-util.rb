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
  end
end

