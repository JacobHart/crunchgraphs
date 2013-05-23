class CreateFinancials < ActiveRecord::Migration
  def change
    create_table :financials do |t|
      t.string :name
      t.string :perma
      t.string :crunch_url
      t.string :home_url
      t.date :founded_date

      t.timestamps
    end
  end
end
