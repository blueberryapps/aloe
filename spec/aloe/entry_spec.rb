# encoding: utf-8

require 'spec_helper'

describe Aloe::Entry do
  it "takes amount in fixnum" do
    subject.amount = 1234
    subject.read_attribute(:amount).should eq 1234
  end

  it "delegates #currency to #account" do
    subject.stub(:account).and_return(double "Account", currency: "GBP")
    subject.currency.should eq "GBP"
  end

  describe '#amount' do
    it 'returns Money instance' do
      subject.send :write_attribute, :amount, 1234
      subject.stub(:account).and_return(double 'Account', currency: 'GBP')
      subject.amount.should eq Money.new(1234, 'GBP')
    end
  end

  describe '#withdrawal?' do
    before do
      subject.stub(:account).and_return(double 'Account', currency: 'GBP')
    end

    context 'given the amount is negative' do
      it 'returns true' do
        subject.send :write_attribute, :amount, -1234
        subject.should be_withdrawal
      end
    end

    context 'given the amount is positive' do
      it 'returns false' do
        subject.send :write_attribute, :amount, 1234
        subject.should_not be_withdrawal
      end
    end
  end
end
