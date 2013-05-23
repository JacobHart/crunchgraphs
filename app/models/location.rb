class Location < ActiveRecord::Base
  attr_accessible :address1, :address2, :city, :countrycode, :latitude, :longitude, :statecode, :zipcode
  belongs_to :company

end
