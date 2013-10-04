module Accounting
  module Reports
    class AccountHistory

      attr_reader :account

      def initialize(account)
        @account = account
      end

      def header
        ['Transaction', 'Credit', 'Debit', 'Amount', 'Time']
      end

      def body
        account.entries.map do |e|
          tr = e.transaction
          [tr.category,
            tr.credit_entry.account.to_s,
            tr.debit_entry.account.to_s,
            e.amount.format,
            e.created_at.to_s]
        end
      end

      def footer
        ['', '', '', account.balance.format, '']
      end

    end
  end
end
