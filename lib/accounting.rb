require 'accounting/ledger'
require 'accounting/engine'
require 'accounting/reports/account_history'
require 'accounting/reports/accounts_list'


module Accounting

  ROLLBACK_TRANSACTION = 'rollback'.freeze

  def self.table_name_prefix
    'accounting_'
  end

end
