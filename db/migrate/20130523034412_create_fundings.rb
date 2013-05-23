class CreateFundings < ActiveRecord::Migration
  def change
    create_table :fundings do |t|
      t.integer :company_id
      t.string :company_perma
      t.string :funding_code
      t.float :funding_amount
      t.string :funding_currency
      t.date :funding_date

      t.timestamps
    end
  end
end
