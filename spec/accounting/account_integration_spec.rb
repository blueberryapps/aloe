# encoding: utf-8

require 'spec_helper'
require 'timecop'

describe 'Account integration spec', integration: true do
  let(:owner) { User.create! }
  let(:owner2) { User.create! }

  describe 'default scope' do
    before do
      closed = create_account owner2, :GBP
      closed.close!
      @account = create_account owner, :GBP
    end

    it 'excludes closed account' do
      Accounting::Account.all.should eq [@account]
    end
  end

  describe '#closed scope' do
    before do
      @closed = create_account owner2, :GBP
      @closed.close!
      account = create_account owner, :GBP
    end

    it 'includes closed accounts only' do
      Accounting::Account.closed.should eq [@closed]
    end
  end

  describe 'default account state' do
    let(:account) { Accounting::Account.new }

    it 'is open' do
      account.state.should eq 'open'
      account.should be_open
    end
  end

  describe 'closing account' do
    context 'an account with zero balance' do
      let(:account) { create_account owner, :GBP }

      it 'can be safely closed' do
        account.close!
        account.should be_closed
      end
    end

    context 'an account with non-zero balance' do
      let(:account) { create_account owner, :GBP }

      before do
        account.update_column :balance, 123
      end

      it 'cannot be closed' do
        lambda do
          account.close!
        end.should raise_error(StateMachine::InvalidTransition)
        account.should_not be_closed
        account.should be_open
      end
    end
  end

  describe 'opening closed account' do
    let(:account) { create_account owner, :GBP }

    before do
      account.close!
    end

    it 'can be safely closed' do
      account.reopen!
      account.should be_open
    end
  end

  describe 'suspending open account' do
    let(:account) { create_account owner, :GBP }

    it 'can be safely closed' do
      account.suspend!
      account.should be_suspended
    end
  end

  describe 'unsuspending suspended account' do
    let(:account) { create_account owner, :GBP }

    before do
      account.suspend!
    end

    it 'can be safely closed' do
      account.unsuspend!
      account.should be_open
    end
  end

  describe '.turnover' do
    let(:account) { create_account owner, :GBP }
    let(:amounts1) { [765, 927, 123, -1239, 212, -232] }
    let(:amounts2) { [23, 123, 145, 7864, -7231] }

    before do
      account.update_column :created_at, 30.days.ago
      Timecop.travel(30.days.ago) do
        amounts1.each { |amount| account.create_entry(amount) }
      end
      Timecop.travel(20.days.ago) do
        amounts2.each { |amount| account.create_entry(amount) }
      end
    end

    it 'returns turnover in given period' do
      account.turnover(21.days.ago..Time.now).should eq Money.new(amounts2.sum, :GBP)
    end
  end

  describe '.balance_at' do
    let(:account) { create_account owner, :GBP }
    let(:amounts1) { [765, 927, 123, -1239, 212, -232] }
    let(:amounts2) { [23, 123, 145, 7864, -7231] }

    before do
      account.update_column :created_at, 30.days.ago
      Timecop.travel(30.days.ago) do
        amounts1.each { |amount| account.create_entry(amount) }
      end
      Timecop.travel(20.days.ago) do
        amounts2.each { |amount| account.create_entry(amount) }
      end
    end

    it 'returns turnover in given period' do
      account.balance_at(29.days.ago).should eq Money.new(amounts1.sum, :GBP)
    end
  end
end
