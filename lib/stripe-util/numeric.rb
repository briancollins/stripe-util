module Stripe
  module Util
    module Numeric

      def self.pretty_amount(amount, currency = '$')
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
end