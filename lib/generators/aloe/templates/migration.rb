class CreateAloeTables < ActiveRecord::Migration

  def change
    create_table :aloe_accounts do |t|
      t.string :name
      t.string :currency, limit: 3
      t.string :state
      t.text :configuration
      t.column :balance, :bigint, default: 0
      t.references :owner, polymorphic: true
      t.timestamps
    end

    add_index :aloe_accounts, [:owner_id, :owner_type]
    add_index :aloe_accounts, :status

    create_table :aloe_entries do |t|
      t.column :amount, :bigint
      t.references :account
      t.timestamps
    end

    add_index :aloe_entries, :account_id

    create_table :aloe_transactions do |t|
      t.string :uuid
      t.string :category
      t.string :code
      t.text :description
      t.text :details
      t.references :credit_entry
      t.references :debit_entry
      t.references :adjustment_transaction
      t.timestamps
    end

    add_index :aloe_transactions, :uuid
    add_index :aloe_transactions, :credit_entry_id
    add_index :aloe_transactions, :debit_entry_id
    add_index :aloe_transactions, :adjustment_transaction_id
    add_index :aloe_transactions, :category
  end

end
