class Individual < ActiveRecord::Base
  attr_accessible :crunch_url, :home_url, :name, :perma

  has_many :investments

end
