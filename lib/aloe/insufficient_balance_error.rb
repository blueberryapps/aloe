module Aloe
  class InsufficientBalanceError < StandardError

    def initialize(account, expected_balance)
      @account, @expected_balance = account, expected_balance
    end

    def to_s
      "Account #{@account} has not enough balance" +
        " - required at least #{@expected_balance}!"
    end

  end
end
