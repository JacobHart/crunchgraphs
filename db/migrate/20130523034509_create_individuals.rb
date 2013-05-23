class CreateIndividuals < ActiveRecord::Migration
  def change
    create_table :individuals do |t|
      t.string :name
      t.string :perma
      t.string :crunch_url
      t.string :home_url

      t.timestamps
    end
  end
end
