require 'date'

module Stripe
  module Util
    class Statement
      attr_reader :to_date, :from_date

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

    end
  end
end
