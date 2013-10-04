module Aloe
  module AccountRepository

    # Scope by currency.
    #
    # @param [String, Symbol] currency Currency symbol
    # @return [ActiveRecord::Relation]
    def currency(currency)
      where(currency: currency)
    end

    # Default scope excludes closed accounts.
    def default_scope
      where('state != ?', 'closed')
    end

    # Scope to closed accounts.
    #
    # @return [ActiveRecord::Relation]
    def closed
      unscoped.with_state('closed')
    end

    # Scope by owner.
    #
    # @param [ActiveRecord::Base] owner
    # @return [ActiveRecord::Relation]
    def owner(owner)
      where(owner_type: owner.class.model_name.to_s, owner_id: owner.id)
    end

    # Return the trial balance.
    #
    # Trial balance is balance of all accounts in the system
    # combined. It should at all times be 0. If it's not, there
    # is an error in accounts somewhere.
    #
    # @param [String, Symbol] currency Currency symbol
    # @return [Fixnum] Zero if everything's fine
    def trial_balance(currency)
      currency(currency).sum :balance
    end

  end
end
