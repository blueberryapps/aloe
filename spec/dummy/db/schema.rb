# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131003203647) do

  create_table "accounting_accounts", force: true do |t|
    t.string   "name"
    t.string   "currency",      limit: 3
    t.string   "state"
    t.text     "configuration"
    t.integer  "balance",                 default: 0
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounting_accounts", ["owner_id", "owner_type"], name: "index_accounting_accounts_on_owner_id_and_owner_type"

  create_table "accounting_entries", force: true do |t|
    t.integer  "amount"
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounting_entries", ["account_id"], name: "index_accounting_entries_on_account_id"

  create_table "accounting_transactions", force: true do |t|
    t.string   "uuid"
    t.string   "category"
    t.string   "code"
    t.text     "description"
    t.text     "details"
    t.integer  "credit_entry_id"
    t.integer  "debit_entry_id"
    t.integer  "adjustment_transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounting_transactions", ["adjustment_transaction_id"], name: "index_accounting_transactions_on_adjustment_transaction_id"
  add_index "accounting_transactions", ["category"], name: "index_accounting_transactions_on_category"
  add_index "accounting_transactions", ["credit_entry_id"], name: "index_accounting_transactions_on_credit_entry_id"
  add_index "accounting_transactions", ["debit_entry_id"], name: "index_accounting_transactions_on_debit_entry_id"
  add_index "accounting_transactions", ["uuid"], name: "index_accounting_transactions_on_uuid"

  create_table "users", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
