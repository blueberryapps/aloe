# encoding: utf-8

require "spec_helper"

describe "Accounting integration spec", integration: true do
  describe "Accounting::Account" do
    it "does not allow duplicate names" do
      create_account 'Test', :GBP
      account = Accounting::Account.new name: "Test", currency: "GBP"
      account.should_not be_valid
    end

    it "does not allow duplicate owners" do
      user = User.create!
      previous_account = create_account user, :GBP
      account = Accounting::Account.new owner: user, currency: "GBP"
      account.should_not be_valid
    end
  end

  describe "Accounting::Ledger.find_account" do
    context "given an account exists" do
      let(:user) { User.create! }

      it "returns given account" do
        create_account user, :GBP
        account = Accounting::Ledger.find_account(user, "GBP")
        account.should be_kind_of Accounting::Account
        account.owner.should eq user
      end
    end
  end

  describe "posting to a ledger" do
    let(:from_account) { create_account 'Debit', :GBP }
    let(:to_account)   { create_account 'Credit', :GBP }
    let(:money)        { Money.new 5000, "GBP" }

    it "manipulates balances" do
      Accounting::Ledger.create_entry money, from: from_account, to: to_account,
        type: 'deposit'
      to_account.balance.should eq money
      from_account.balance.should eq -money
    end

    context "given different currency" do
      it "raises exception when given amount is of different currency" do
        money = Money.new 5000, "USD"
        lambda do
          Accounting::Ledger.create_entry money, from: from_account,
            to: to_account,
            type: 'deposit'
        end.should raise_error Accounting::InvalidCurrencyError
      end
    end

    context "given that accounts are of different currency" do
      let(:to_account) { create_account 'Credit', :USD }

      it "raises exception when given amount is of different currency" do
        lambda do
          Accounting::Ledger.create_entry money, from: from_account, to: to_account,
            type: 'deposit'
        end.should raise_error Accounting::InvalidCurrencyError
      end
    end

    context "given debit account cannot have negative balance" do
      let(:configuration) { Accounting::AccountConfiguration.new allow_negative_balance: false }
      let(:from_account)  { create_account 'Debit', :GBP, configuration: configuration }

      it "raises exception" do
        lambda do
          Accounting::Ledger.create_entry money, from: from_account, to: to_account,
            type: 'deposit'
        end.should raise_error Accounting::InsufficientBalanceError
        to_account.balance.should be_zero
        from_account.balance.should be_zero
      end
    end

    context "given debit account is closed" do
      let(:from_account)  { create_account 'Debit', :GBP }

      before do
        from_account.close!
      end

      it "manipulates balances" do
        lambda do
          Accounting::Ledger.create_entry money, from: from_account,
            to: to_account,
            type: 'deposit'
        end.should raise_error Accounting::InoperableAccountError
        to_account.balance.should be_zero
        from_account.balance.should be_zero
      end
    end

    context "given debit account is suspended" do
      let(:from_account)  { create_account 'Debit', :GBP }

      before do
        from_account.suspend!
      end

      it "manipulates balances" do
        lambda do
          Accounting::Ledger.create_entry money, from: from_account,
            to: to_account,
            type: 'deposit'
        end.should raise_error Accounting::InoperableAccountError
        to_account.balance.should be_zero
        from_account.balance.should be_zero
      end
    end
  end

  describe "rolling back transactions" do
    let(:from_account) { create_account 'Debit', :GBP }
    let(:to_account)   { create_account 'Credit', :GBP }
    let(:money)        { Money.new 5000, "GBP" }

    before do
      @transaction = Accounting::Ledger.create_entry money,
        from: from_account, to: to_account,
        type: 'deposit'
    end

    it "creates balancing transaction" do
      @transaction.rollback
      from_account.entries.size.should eq 2
      to_account.entries.size.should eq 2
      Accounting::Transaction.last.type.should eq Accounting::ROLLBACK_TRANSACTION
      Accounting::Transaction.last.type.should eq Accounting::ROLLBACK_TRANSACTION
    end

    it "balances accounts" do
      @transaction.rollback
      from_account.reload.balance.should be_zero
      to_account.reload.balance.should be_zero
    end
  end

  describe "handling concurent transactions" do
    let(:configuration) { Accounting::AccountConfiguration.new allow_negative_balance: false }
    let(:from_account) { create_account 'Debit', :GBP, configuration: configuration }
    let(:to_account)   { create_account 'Credit', :GBP, configuration: configuration }
    let(:source)       { create_account 'Source', :GBP }
    let(:money)        { Money.new 5000, "GBP" }

    before do
      Accounting::Ledger.create_entry money, from: source,
        to: from_account,
        type: 'deposit'
    end

    it "shouldn't allow concurent transactions" do
      from_account_copy = Accounting::Account.find(from_account.id)
      Accounting::Ledger.create_entry money, from: from_account,
        to: to_account,
        type: 'deposit'
      expect do
        Accounting::Ledger.create_entry money, from: from_account_copy,
          to: to_account,
          type: 'deposit'
      end.to raise_error(Accounting::InsufficientBalanceError)
      to_account.balance.should eq money
    end
  end
end

