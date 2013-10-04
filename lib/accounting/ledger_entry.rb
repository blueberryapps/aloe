require 'accounting/invalid_currency_error'
require 'accounting/invalid_amount_error'
require 'accounting/insufficient_balance_error'
require 'accounting/inoperable_account_error'

module Accounting
  # LedgerEntry is use-case class that encompasses the process of moving funds
  # between accounts.
  class LedgerEntry < Struct.new(:amount, :options)

    def initialize(*args)
      super
      raise Accounting::InvalidAmountError if amount.zero?
      unless same_currencies?
        raise Accounting::InvalidCurrencyError.new(debit_account, credit_account,
          amount.currency)
      end
      unless debit_account.open?
        raise Accounting::InoperableAccountError.new(debit_account)
      end
      unless credit_account.open?
        raise Accounting::InoperableAccountError.new(credit_account)
      end
    end

    def create!
      ActiveRecord::Base.transaction do
        debit_entry = debit_account.create_entry(-amount.cents)
        credit_entry = credit_account.create_entry(amount.cents)
        attributes = { credit_entry: credit_entry,
                       debit_entry: debit_entry,
                       category: category }.merge options
        Accounting::Transaction::create! attributes
      end
    end

    protected

    def category
      @category ||= options.delete(:type)
    end

    # @return [Accounting::Account]
    def credit_account
      @credit_account ||= may_find_account(options.delete(:to), currency)
    end

    # @return [String]
    def currency
      @currency ||= amount.currency
    end

    # @return [Accounting::Account]
    def debit_account
      @debit_account ||= may_find_account(options.delete(:from), currency)
    end

    # @return [Class]
    def ledger
      Accounting::Ledger
    end

    # @param [Object, Accounting::Accounting] account_or_owner
    # @param [String, Symbol] currency
    # @return [Accounting::Account]
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
