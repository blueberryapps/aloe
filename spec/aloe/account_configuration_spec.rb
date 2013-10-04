# encoding: utf-8

require "spec_helper"

describe Aloe::AccountConfiguration do
  describe "#allow_negative_balance" do
    it "is true by default" do
      subject.allow_negative_balance.should be_true
    end

    it "return true if underlying variable is true" do
      subject.allow_negative_balance = true
      subject.allow_negative_balance.should be_true
    end

    it "return false if underlying variable is false" do
      subject.allow_negative_balance = false
      subject.allow_negative_balance.should be_false
    end
  end
end
