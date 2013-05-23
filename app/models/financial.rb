class Financial < ActiveRecord::Base
  attr_accessible :crunch_url, :founded_date, :home_url, :name, :perma

  has_many :investments

end
