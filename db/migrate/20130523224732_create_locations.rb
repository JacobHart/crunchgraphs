class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :address1
      t.string :address2
      t.string :zipcode
      t.string :city
      t.string :statecode
      t.string :countrycode
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
