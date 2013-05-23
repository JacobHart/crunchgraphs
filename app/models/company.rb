class Company < ActiveRecord::Base
  attr_accessible :crunch_url, :dead_date, :founded_date, :home_url, :industry_id, :name, :perma

  belongs_to :industry
  has_many :investments
  has_many :fundings
  has_one :location

end
