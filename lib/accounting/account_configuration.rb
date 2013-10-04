module Accounting
  class AccountConfiguration

    attr_writer :allow_negative_balance

    def initialize(attrs = {})
      attrs.each do |k ,v|
        public_send :"#{k}=", v
      end
    end

    # Does the account allow negative balance?
    # Defaults to true if no values is provided
    #
    # @return [true, false]
    def allow_negative_balance
      @allow_negative_balance == false ? false : true
    end

  end
end
