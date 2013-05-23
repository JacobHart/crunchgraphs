class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :perma
      t.integer :industry_id
      t.string :crunch_url
      t.string :home_url
      t.date :founded_date
      t.date :dead_date

      t.timestamps
    end
  end
end
