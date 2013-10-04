require 'accounting/account'
require 'accounting/transaction'
require 'accounting/ledger_entry'
require 'money'

module Accounting
  # Ledger is the façade interface to the account. When manipulating accounts
  # (eg. creating transactions between accounts) you should use the Ledger and
  # not the underlying models.
  module Ledger

    extend self

    attr_writer :account_scope

    # Returns an account for given owner.
    #
    # @param [Object, Symbol] owner Account owner or account name
    # @param [String, Symbol] currency Currency symbol
    # @return [Accounting::Account, nil] Account which belongs to given object
    #   or nil
    def find_account(owner, currency = default_currency)
      scope_for_owner(owner).currency(currency.to_s).first
    end

    # Returns accounts for a given owner.
    #
    # @param [Object, Symbol] owner Account owner or account name
    # @param [String, Symbol] currency Currency symbol
    # @return [Accounting::Account, nil] Array of accounts which belongs to
    #   given object
    def find_accounts(owner, currency = nil)
      scope = scope_for_owner(owner)
      currency ? scope.currency(currency) : scope
    end

    # Creates entry in the ledger.
    #
    # Creates entries in both credit and debit account and linking
    # transaction between those two entries. Credit and debit accounts
    # and given amount have to be in the same currency otherwise an
    # exception is raised.
    #
    # @param [Money] amount The amount of money
    # @param [Hash] options Options
    # @option options [Accounting::Account] :from Account which to debit
    # @option options [Accounting::Account] :to Account which to credit
    # @option options [Fixnum] :type Type of transaction
    # @return [Accounting::Transaction]
    def create_entry(amount, options)
      Accounting::LedgerEntry.new(amount, options).create!
    end

    # Return the default currency that gets used when no currency is specified.
    #
    # @return [String]
    def default_currency
      Money.default_currency.to_s
    end

    protected

    # Return the scope for account with given owner.
    #
    # @param [Object]
    # @return [ActiveRecord::Relation]
    def scope_for_owner(owner)
      if owner.class.respond_to?(:model_name)
        account_scope.owner(owner)
      else
        account_scope.where(name: owner.to_s.titleize)
      end
    end

    # Return the scope for Accounts repository.
    #
    # @return [ActiveRecord::Relation]
    def account_scope
      @account_scope ||= Accounting::Account.unscoped
    end

  end
end
