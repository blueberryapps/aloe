require 'aloe/account'
require 'aloe/transaction'
require 'active_record'
require 'money'

module Aloe
  class Entry < ActiveRecord::Base

    # Scopes

    default_scope do
      order('aloe_entries.created_at DESC')
    end

    scope :withdrawals, -> { where('amount < 0') }
    scope :deposits,    -> { where('amount > 0') }

    # Associations

    belongs_to :account, class_name: "Aloe::Account"
    has_one :credit_transaction, class_name: "Aloe::Transaction",
                                 foreign_key: "credit_entry_id"
    has_one :debit_transaction, class_name: "Aloe::Transaction",
                                foreign_key: "debit_entry_id"

    # Instance methods

    delegate :currency, to: :account

    # Return the amount of entry
    #
    # @return [Money] The amount
    def amount
      Money.new read_attribute(:amount), currency
    end
    #
    # Return the related transaction.
    #
    # @return [Aloe::Transaction]
    def transaction
      credit_transaction || debit_transaction
    end

    # Is the entry deposit of funds?
    #
    # @return [true, false]
    def deposit?
      !withdrawal?
    end

    # Is the entry withdrawal of funds?
    #
    # @return [true, false]
    def withdrawal?
      amount.negative?
    end

  end
end
