class CreateInvestments < ActiveRecord::Migration
  def change
    create_table :investments do |t|
      t.integer :funding_id
      t.string :investor_perma
      t.integer :investor_id

      t.timestamps
    end
  end
end
