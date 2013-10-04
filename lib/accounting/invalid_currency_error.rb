module Accounting
  class InvalidCurrencyError < StandardError

    def initialize(credit_account, debit_account, currency)
      @credit_account = credit_account
      @debit_account = debit_account
      @currency = currency
    end

    def to_s
      "Different currencies on accounts #{@credit_account}, #{@debit_account}" +
        " - expected #{@currency}."
    end

  end
end
