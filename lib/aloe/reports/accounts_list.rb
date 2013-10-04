module Aloe
  module Reports
    class AccountsList

      attr_reader :currency

      def initialize(currency = Money.default_currency.to_s)
        @currency = currency
      end

      def header
        ['Type', 'Id', 'Name', 'Owner', 'Currency', 'Balance']
      end

      def body
        accounts.map do |a|
          type = a.name? ? 'System' : 'Entity'
          [type, a.id, a.name, a.owner_type_and_id, a.currency, a.balance.format]
        end
      end

      def footer
        ['', '', '', '', '', trial_balance.format]
      end

      protected

      def accounts
        @accounts ||= Aloe::Account.currency(@currency).all
      end

      def trial_balance
        amount = Aloe::Account.trial_balance(@currency)
        Money.new(amount, @currency)
      end

    end
  end
end
