require 'accounting/account_repository'
require 'accounting/account_configuration'
require 'accounting/entry'
require 'active_record'
require 'money'
require 'state_machine'
require 'active_support/core_ext/object/with_options'

module Accounting
  class Account < ActiveRecord::Base

    extend Accounting::AccountRepository

    # Associations

    belongs_to :owner, polymorphic: true
    has_many :entries, class_name: "Accounting::Entry", include: :account
    has_many :debit_transactions, through: :entries
    has_many :credit_transactions, through: :entries

    # Validations

    validates :currency, presence: true
    with_options scope: :currency do |opts|
      opts.validates_uniqueness_of :name, if: ->{ name? }
    end
    validate :uniqueness_of_owner

    # State machine

    # An account can have following states:
    #   * open - can be manipulated
    #   * suspended - cannot be manipulated, needs to be unsuspended first
    #   * closed - cannot be manipulated, only with 0 balance
    state_machine :state, initial: :open do
      event :close do
        transition all => :closed, if: :closeable?
      end

      event :reopen do
        transition :closed => :open
      end

      event :suspend do
        transition all => :suspended
      end

      event :unsuspend do
        transition :suspended => :open
      end
    end

    # Instance methods

    serialize :configuration, Accounting::AccountConfiguration

    delegate :allow_negative_balance, to: :configuration

    # Return the balance of account
    #
    # @return [Money] The balance
    def balance
      Money.new read_attribute(:balance), currency
    end

    # Computes the balance of the account at the requested date and time.
    # Returns nil if the account did not exist at that time.
    #
    # @param [Time] the date and time
    # @return [Money] the past balance
    def balance_at(time)
      return nil unless created_at <= time
      amount = entries.where('created_at >= ?', time).sum(&:amount)
      offset = amount == 0 ? Money.new(0, currency) : amount
      balance - offset
    end

    # Does account have minimum given balance?
    #
    # @param [Money, Fixnum] amount Amount in question in cents
    # @param [NilClass, Symbol] option Option
    # @return [true, false]
    def balance_of?(amount, option = nil)
      reload if option == :reload
      cents_amount = amount.respond_to?(:cents) ? amount.cents : amount
      read_attribute(:balance) >= cents_amount
    end

    # Can the account be closed?
    #
    # An account can be closed only if the balance is 0.
    #
    # @return [true, false]
    def closeable?
      balance.zero?
    end

    # Creates entry in the account.
    #
    # Creates new entry and modified the balance.
    #
    # @param [Fixnum] cents_amount Amount in cents
    # @return [Accounting::Entry] Created entry
    def create_entry(cents_amount)
      with_lock(true) do
        if cents_amount < 0 && !debit_possible?(-cents_amount)
          raise Accounting::InsufficientBalanceError.new(self, -cents_amount)
        end
        entry = entries.create! amount: cents_amount
        increment! :balance, cents_amount
        entry
      end
    end

    # Is account in given currency?
    #
    # @param [Currency, Symbol, String] currency_in_question
    # @return [true, false]
    def currency?(currency_in_question)
      currency.to_s == currency_in_question.to_s
    end

    # Is the debit of given amount possible?
    #
    # @param [Money, Fixnum] amount Amount in question in cents
    # @return [true, false]
    def debit_possible?(amount)
      allow_negative_balance ? true : balance_of?(amount, :reload)
    end

    # Rolls back all transactions on this account.
    def rollback_all
      transactions = entries.map &:transaction
      transactions.map &:rollback
    end

    # Return string representation of account.
    #
    # @return [String]
    def to_s
      name? ? name : owner_type_and_id
    end

    # Return account turnover over given period of time.
    #
    # @param [Range] period
    # @return [Money]
    def turnover(period)
      turnover = entries.where(created_at: period).sum &:amount
      turnover == 0 ? Money.new(0, currency) : turnover
    end

    # Return account owner type and it's ID.
    #
    # @return [String]
    def owner_type_and_id
      "#{owner_type} #{owner_id}" if owner.present?
    end

    protected

    def uniqueness_of_owner
      if has_conflicting_account_for_owner?
        message = I18n.t('accounting.accounts.errors.owner_already_has_account')
        errors.add(:owner, message)
      end
    end

    def has_conflicting_account_for_owner?
      new_record? && owner.present? &&
        self.class.owner(owner).currency(currency).where(name: name).exists?
    end

  end
end

