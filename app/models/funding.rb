class Funding < ActiveRecord::Base
  attr_accessible :company_id, :company_perma, :funding_amount, :funding_code, :funding_currency, :funding_date

  belongs_to :company
  has_many :investments


end
