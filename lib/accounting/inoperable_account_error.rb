module Accounting
  class InoperableAccountError < StandardError
    def initialize(account)
      @account = account
    end

    def to_s
      "Account #{@account} is inoperable! (account state: #{@account.state})"
    end
  end
end
