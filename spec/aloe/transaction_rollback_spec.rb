# encoding: utf-8

require 'spec_helper'

describe Aloe::TransactionRollback do

  describe "#rollback!" do
    let(:credit_amount) { Money.new 1230 }
    let(:credit_account) { double 'CreditAccount', create_entry: nil }
    let(:credit_entry) { double 'CreditEntry', account: credit_account, amount: credit_amount }
    let(:debit_amount) { Money.new -1230 }
    let(:debit_account) { double 'CreditAccount', create_entry: nil }
    let(:debit_entry) { double 'CreditEntry', account: debit_account, amount: debit_amount }
    let(:transaction) do
      double 'Transaction',
        credit_entry: credit_entry,
        debit_entry: debit_entry,
        update_attribute: nil
    end

    subject { Aloe::TransactionRollback.new(transaction) }

    before do
      Aloe::Transaction.stub(:create!)
    end

    it 'creates debit entry on credit account' do
      credit_account.should_receive(:create_entry).with debit_amount.cents
      subject.rollback!
    end

    it 'creates credit entry on debit account' do
      debit_account.should_receive(:create_entry).with credit_amount.cents
      subject.rollback!
    end

    it 'creates a rollback transaction' do
      Aloe::Transaction
        .should_receive(:create!)
      subject.rollback!
    end

    it 'sets adjustment transaction on original transaction' do
      transaction.should_receive(:update_attribute)
      subject.rollback!
    end
  end

end
