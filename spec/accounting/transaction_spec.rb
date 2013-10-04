# encoding: utf-8

require 'spec_helper'

describe Accounting::Transaction do

  describe "#entries" do
    it "returns credit_entry and debit_entry in an array" do
      credit_entry = double "credit entry"
      debit_entry = double "debit entry"
      subject.stub(:credit_entry).and_return credit_entry
      subject.stub(:debit_entry).and_return debit_entry
      subject.entries.should eq [debit_entry, credit_entry]
    end
  end

  describe "#details" do
    it "return empty hash if nil value given" do
      subject.details.should be_empty
    end
  end

  describe "#amount" do
    it "returns absolute credit_entry amount value" do
      credit_entry = double "credit entry", amount: -1234
      subject.stub(:credit_entry).and_return credit_entry
      subject.amount.should eq 1234
    end
  end

  describe "#rollback" do
    let(:rollback) { double 'TransactionRollback', rollback!: nil }

    before do
      Accounting::TransactionRollback.stub(:new).and_return rollback
    end

    it "creates new TransactionRollback object and calls rollback on it" do
      rollback.should_receive :rollback!
      subject.rollback
    end
  end

  describe "#uuid" do
    let(:subject2) { Accounting::Transaction.new }

    it "is assigned for each new transaction" do
      subject.run_callbacks :create
      subject.uuid.should_not be_empty
    end

    it "assigns unique UUID to each instance" do
      subject.run_callbacks :create
      subject2.run_callbacks :create
      subject.uuid.should_not eq(subject2.uuid)
    end
  end

end
