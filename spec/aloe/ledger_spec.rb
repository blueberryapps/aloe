# encoding: utf-8

require "spec_helper"

describe Aloe::Ledger, unit: true do
  subject { Aloe::Ledger }

  describe ".find_account" do
    let(:account_scope) { double "AccountScope" }

    before do
      subject.account_scope = account_scope
    end

    context "an account exists" do
      let(:user)    { mock_model "User" }
      let(:account) { double "Account" }

      context "given AR object" do
        it "returns given account" do
          account_scope.stub_chain(:owner, :currency).and_return [account]
          currency = "CZK"
          account_scope.should_receive(:owner).with user
          subject.find_account(user, currency) .should eq account
        end
      end

      context "given symbol" do
        it "finds an account by name" do
          account_scope.stub_chain(:where, :currency).and_return [account]
          account_scope.should_receive(:where).with(name: "Deposits")
          subject.find_account(:deposits).should eq account
        end
      end
    end

    context "an account does not exist" do
      it "returns nil" do
        account_scope.stub_chain(:where, :currency).and_return []
        subject.find_account(:deposits).should be_nil
      end
    end
  end

  describe ".find_accounts" do
    let(:account_scope) { double "AccountScope" }

    before do
      subject.account_scope = account_scope
    end

    let(:user)     { mock_model "User" }
    let(:accounts) { double "Accounts" }

    context "given AR object and currency" do
      let(:currency) { "CZK" }

      it "returns given account" do
        account_scope.stub_chain(:owner, :currency).and_return accounts
        account_scope.should_receive(:owner).with user
        subject.find_accounts(user, currency) .should eq accounts
      end
    end

    context "given symbol only" do
      it "finds an account by name" do
        account_scope
          .should_receive(:where)
          .with(name: "Deposits")
          .and_return accounts
        subject.find_accounts(:deposits).should eq accounts
      end
    end
  end

  describe ".create_entry" do
    let(:ledger_entry) { double "LedgerEntry", create!: nil }
    let(:amount) { Money.new 5000 }
    let(:options) { {} }

    before do
      Aloe::LedgerEntry.stub(:new).and_return ledger_entry
    end

    it "creates LedgerEntry object and calls create!" do
      ledger_entry.should_receive(:create!)
      subject.create_entry(amount, options)
    end
  end
end
