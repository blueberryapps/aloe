require 'terminal-table'

task :aloe do

  desc "Show overview of accounts and their balances"
  task :list_accounts => :environment do
    currency = ENV["CURRENCY"].presence || Money.default_currency.to_s
    report = Aloe::Reports::AccountsList.new currency
    rows = report.body + [:separator] + [report.footer]
    table = Terminal::Table.new headings: report.header, rows: rows
    table.align_column(5, :right)
    puts table
  end

  desc "Show history of account"
  task :account_history => :environment do
    account = Aloe::Account.find ENV["ACCOUNT_ID"]
    report = Aloe::Reports::AccountHistory.new(account)
    rows = report.body + [:separator] + [report.footer]
    table = Terminal::Table.new headings: report.header, rows: rows
    puts table
  end

end
