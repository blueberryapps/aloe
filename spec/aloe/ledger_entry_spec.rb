# encoding: utf-8

require 'spec_helper'

describe Aloe::LedgerEntry do
  describe ".create_entry" do
    let(:debit_account) { double 'DebitAccount', currency?: true,
      create_entry: debit_entry, open?: true }
    let(:credit_account) { double 'CreditAccount', currency?: true,
      create_entry: credit_entry, open?: true }
    let(:credit_entry) { double 'CreditEntry' }
    let(:debit_entry) { double 'DebitEntry' }
    let(:transaction) { double 'Transaction' }
    let(:amount) { Money.new 5000, :GBP }
    let(:options) { { from: debit_account, to: credit_account, type: 123 } }
    subject { Aloe::LedgerEntry.new amount, options }

    before do
      Aloe::Transaction.stub(:create!)
    end

    it "checks if credit and debit accounts are of given currency" do
      debit_account.should_receive(:currency?).with(amount.currency).and_return true
      credit_account.should_receive(:currency?).with(amount.currency).and_return true
      subject.create!
    end

    it "creates entry on debit and credit account" do
      debit_account.should_receive(:create_entry).with(-5000)
      credit_account.should_receive(:create_entry).with(5000)
      subject.create!
    end

    it "creates transaction" do
      Aloe::Transaction
        .should_receive(:create!)
        .with(credit_entry: credit_entry, debit_entry: debit_entry, category: 123)
        .and_return transaction
      subject.create!.should eq transaction
    end

    context "account owners given instead of accounts" do
      let(:debit_owner) { double "debit owner" }
      let(:credit_owner) { double "credit owner" }

      it "finds accounts" do
        Aloe::Ledger
          .should_receive(:find_account)
          .with(credit_owner, amount.currency)
          .and_return credit_account
        Aloe::Ledger
          .should_receive(:find_account)
          .with(debit_owner, amount.currency)
          .and_return debit_account
        Aloe::LedgerEntry.new(amount, from: debit_owner, to: credit_owner,
                                       type: 123).create!
      end
    end

    context "given different currency" do
      let(:amount) { Money.new 5000, :CZK }

      it "raises InvalidCurrencyError if given different currency" do
        lambda do
          debit_account.stub(:currency?).and_return false
          subject.create!
        end.should raise_error(Aloe::InvalidCurrencyError)
      end
    end

    context "given 0 amount" do
      let(:amount) { 0 }

      it "raises InvalidAmountError" do
        lambda do
          subject.create!
        end.should raise_error(Aloe::InvalidAmountError)
      end
    end

    context "given closed or freezed debit amount" do
      before do
        debit_account.stub(:open?).and_return false
      end

      it "raises InoperableAccountError" do
        lambda do
          subject.create!
        end.should raise_error(Aloe::InoperableAccountError)
      end
    end

    context "given closed or freezed credit amount" do
      before do
        credit_account.stub(:open?).and_return false
      end

      it "raises InoperableAccountError" do
        lambda do
          subject.create!
        end.should raise_error(Aloe::InoperableAccountError)
      end
    end
  end
end
