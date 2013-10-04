require 'aloe/invalid_currency_error'
require 'aloe/invalid_amount_error'
require 'aloe/insufficient_balance_error'
require 'aloe/inoperable_account_error'

module Aloe
  # LedgerEntry is use-case class that encompasses the process of moving funds
  # between accounts.
  class LedgerEntry < Struct.new(:amount, :options)

    def initialize(*args)
      super
      raise Aloe::InvalidAmountError if amount.zero?
      unless same_currencies?
        raise Aloe::InvalidCurrencyError.new(debit_account, credit_account,
          amount.currency)
      end
      unless debit_account.open?
        raise Aloe::InoperableAccountError.new(debit_account)
      end
      unless credit_account.open?
        raise Aloe::InoperableAccountError.new(credit_account)
      end
    end

    def create!
      ActiveRecord::Base.transaction do
        debit_entry = debit_account.create_entry(-amount.cents)
        credit_entry = credit_account.create_entry(amount.cents)
        attributes = { credit_entry: credit_entry,
                       debit_entry: debit_entry,
                       category: category }.merge options
        Aloe::Transaction::create! attributes
      end
    end

    protected

    def category
      @category ||= options.delete(:type)
    end

    # @return [Aloe::Account]
    def credit_account
      @credit_account ||= may_find_account(options.delete(:to), currency)
    end

    # @return [String]
    def currency
      @currency ||= amount.currency
    end

    # @return [Aloe::Account]
    def debit_account
      @debit_account ||= may_find_account(options.delete(:from), currency)
    end

    # @return [Class]
    def ledger
      Aloe::Ledger
    end

    # @param [Object, Aloe::Aloe] account_or_owner
    # @param [String, Symbol] currency
    # @return [Aloe::Account]
    def may_find_account(account_or_owner, currency)
      if account_or_owner.respond_to?(:create_entry)
        account_or_owner
      elsif account_or_owner
        ledger.find_account account_or_owner, currency
      end
    end

    # Are the two accounts of the matching currency as the given amount?
    #
    # @return [true, false]
    def same_currencies?
      debit_account.currency?(amount.currency) &&
        credit_account.currency?(amount.currency)
    end

  end
end
