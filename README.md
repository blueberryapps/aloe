# Accounting gem

Accouning is Ruby gem that provides double-entry bookkeeping infrastructure 
for Rails.

## Instalation

Add accounting gem into your Gemfile:

    gem 'accounting'

Generate the migration:

    rails generate accounting

Then run the migrations:

    rake db:migrate

## Example usage:

Each account must name, owner or both. Owner is an entity in your application, 
for example following piece of code returns account belonging to the user:

    user = User.first
    account = Accounting::Ledger.find_account(user, :USD)

Moving money from one account to another is accomplished by creating an entry
in the ledger:

    amount = Money.new(500, :USD)
    Accounting::Ledger.create_entry money, from: debit_account, to: credit_accoun,

## TODO

* Multi-legged transactions support
* Currency converting transactions

## Dependencies

Accounting is Rails 4 engine. All models are based on ActiveRecord.

[Money](https://github.com/RubyMoney/money) is used for handling monetary 
values.

## Issues

If you have problems, please create a
[Github Issue](https://github.com/blueberryapps/accounting/issues).

## License

Accounting is Copyright © 2013 Blueberry.cz Apps s.r.o. It is free software, 
and may be redistributed under the terms specified in the LICENSE file.
