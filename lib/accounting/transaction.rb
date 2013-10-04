require 'accounting/entry'
require 'accounting/transaction_rollback'
require 'active_record'
require 'uuid'

module Accounting
  class Transaction < ActiveRecord::Base

    # Associations

    belongs_to :credit_entry, class_name: "Accounting::Entry"
    has_one    :credit_account, through: :credit_entry, source: :account
    belongs_to :debit_entry, class_name: "Accounting::Entry"
    has_one    :debit_account, through: :debit_entry, source: :account
    belongs_to :adjustment_transaction, class_name: "Transaction"
    has_one    :adjusted_transaction, class_name: "Transaction",
                                      foreign_key: "adjustment_transaction_id"

    # Validations

    validates_presence_of :credit_entry
    validates_presence_of :debit_entry
    validates_presence_of :category

    # Callbacks

    before_create :assign_uuid

    # Instance methods

    serialize :details

    # Return transaction details hash.
    #
    # @return [Hash]
    def details
      attributes["details"] ||= {}
    end

    # Return entries of transaction.
    #
    # @return [Array<Accounting::Entry>]
    def entries
      [debit_entry, credit_entry]
    end

    # Return the type of transaction.
    #
    # Type of transaction is stored in +category+ attribute
    # internally because AR uses +type+ for STI.
    #
    # @return [Fixnum]
    def type
      category
    end

    # Returns the amount of transaction.
    #
    # @return [Money]
    def amount
      credit_entry.amount.abs
    end

    # Rollback transaction by creating balancing entries.
    def rollback
      Accounting::TransactionRollback.new(self).rollback!
    end

    def number
      uuid.first(8)
    end

    protected

    def assign_uuid
      write_attribute :uuid, UUID.new.generate(:compact)
    end

  end
end
