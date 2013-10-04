# encoding: utf-8

require 'spec_helper'

describe Accounting::Account do
  describe "#configuration" do
    it "returns AccountConfiguration instance by default" do
      subject.configuration.should be_kind_of Accounting::AccountConfiguration
    end
  end

  describe "#allow_negative_balance" do
    it "delegates request to configuration" do
      configuration = double "account configuration"
      subject.stub(:configuration).and_return configuration
      configuration.should_receive(:allow_negative_balance).and_return true
      subject.allow_negative_balance.should be_true
    end
  end

  describe "#balance" do
    it "returns instance of Money value" do
      subject.currency = "CZK"
      subject.balance = 1234
      subject.balance.should eq Money.new(1234, "CZK")
    end
  end

  describe "#balance_of?" do
    before(:each) do
      subject.balance = 500
    end

    context "given fixnum cents" do
      it "returns true when available balance is more than or equals to given number" do
        subject.balance_of?(500).should be_true
        subject.balance_of?(35).should be_true
      end

      it "returns false when available balance is less than given number" do
        subject.balance_of?(501).should be_false
        subject.balance_of?(990).should be_false
      end
    end

    context "given Money instance" do
      it "returns true when available balance is more than or equals to given number" do
        subject.balance_of?(Money.new(500)).should be_true
        subject.balance_of?(Money.new(35)).should be_true
      end

      it "returns false when available balance is less than given number" do
        subject.balance_of?(Money.new(501)).should be_false
        subject.balance_of?(Money.new(990)).should be_false
      end

    end
  end

  describe "#closeable?" do
    context "given the balance is zero" do
      it "returns true" do
        subject.should be_closeable
      end
    end

    context "given the balance is non-zero" do
      it "returns false" do
        subject.stub(:balance).and_return Money.new 100
        subject.should_not be_closeable
      end
    end
  end

  describe "#create_entry" do
    before do
      subject.currency = "GBP"
      subject.save!
    end

    it "creates entry" do
      subject.create_entry 500
      subject.entries.size.should eq 1
    end

    it "modifies the balance" do
      subject.create_entry 500
      subject.balance.should eq Money.new(500, "GBP")
    end

    it "returns created entry" do
      entry = subject.create_entry(500)
      entry.should be_kind_of(Accounting::Entry)
      entry.amount.should eq Money.new(500, :GBP)
    end
  end

  describe "#currency?" do
    it "checks whether account is of asked currency" do
      subject.currency = "GBP"
      subject.currency?(:GBP).should be_true
      subject.currency?("GBP").should be_true
      subject.currency?("USD").should be_false
    end
  end

  describe "#rollback_all" do
    it "calls rollback on all transactions" do
      t1 = double("t1")
      t2 = double("t2")
      entries = [double("e1", transaction: t1), double("e2", transaction: t2)]
      subject.stub(:entries).and_return entries
      t1.should_receive(:rollback)
      t2.should_receive(:rollback)
      subject.rollback_all
    end
  end

  describe "#balance_at" do
    before do
      subject.stub(:currency).and_return 'GBP'
      subject.stub_chain(:entries, :where).and_return entries
    end

    context 'given date before the account was created' do
      let(:entries) { [] }

      before do
        subject.stub(:created_at).and_return Time.now
      end

      it "should have nil balance before it was created" do
        subject.balance_at(1.year.ago).should be_nil
      end
    end

    context 'given there are entries and correct date given' do
      let(:balance) { 84920123 }
      let(:amounts) { [4858, -75785, 5951, -9958, 99485, 885496, 9983] }
      let(:entries) do
        amounts.map do |amount|
          double "Entry", amount: amount
        end
      end

      before do
        subject.stub(:balance).and_return balance
        subject.stub(:created_at).and_return 30.days.ago
      end

      it "should give the correct past balance" do
        subject.balance_at(29.days.ago).should eq(balance - amounts.sum)
      end
    end
  end

  describe "#turnover" do
    before do
      subject.stub_chain(:entries, :where).and_return entries
      subject.stub(:currency).and_return 'GBP'
    end

    context "given there are any entries" do
      let(:amounts) { [1234, 500, -1234, 600, -100] }
      let(:entries) do
        amounts.map do |amount|
          double "Entry", amount: amount
        end
      end

      it "returns turnover over given period of time" do
        subject.turnover(1.month.ago..Time.now).should eq 1000
      end
    end

    context "given there are no entries" do
      let(:entries) { [] }

      before do
        subject.stub_chain(:entries, :where).and_return entries
      end

      it "returns Money instance with 0" do
        zero = Money.new(0, 'GBP')
        subject.turnover(1.month.ago..Time.now).should eq zero
      end
    end
  end
end
