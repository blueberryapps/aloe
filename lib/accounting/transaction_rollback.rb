module Accounting
  # Use case class for rolling back a transaction.
  class TransactionRollback < Struct.new(:transaction)

    def rollback!
      ActiveRecord::Base.transaction do
        e1 = credit_entry.account.create_entry debit_entry.amount.cents
        e2 = debit_entry.account.create_entry credit_entry.amount.cents
        rollback = Accounting::Transaction.create! credit_entry: e2,
          debit_entry: e1,
          category: Accounting::ROLLBACK_TRANSACTION
        transaction.update_attribute :adjustment_transaction, rollback
      end
    end

    private

    # Return credit entry of the transaction.
    #
    # @return [Accounting::Entry]
    def credit_entry
      transaction.credit_entry
    end

    # Return debit entry of the transaction.
    #
    # @return [Accounting::Entry]
    def debit_entry
      transaction.debit_entry
    end

  end
end

