# encoding: utf-8

module AccountHelpers
  # Create account with given owner and currency.
  #
  # @param [Object] owner
  # @param [Symbol, String] currency
  # @return [Accounting::Account]
  def create_account(owner_or_name, currency, attrs = {})
    if owner_or_name.is_a?(ActiveRecord::Base)
      attrs[:owner] = owner_or_name
    else
      attrs[:name] = owner_or_name
    end
    Accounting::Account.create! attrs.merge(currency: currency)
  end
end
