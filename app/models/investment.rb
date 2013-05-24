class Investment < ActiveRecord::Base
  attr_accessible :funding_id, :company_peram, :company_id, :financial_perma, :financial_id, :individual_perma, :individual_id

  belongs_to :company
  belongs_to :individual
  belongs_to :financial
  belongs_to :funding


end
