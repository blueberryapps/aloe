require 'aloe/ledger'
require 'aloe/engine'
require 'aloe/reports/account_history'
require 'aloe/reports/accounts_list'

module Aloe

  ROLLBACK_TRANSACTION = 'rollback'.freeze

  def self.table_name_prefix
    'aloe_'
  end

end
