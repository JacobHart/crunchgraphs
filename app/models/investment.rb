class Investment < ActiveRecord::Base
  attr_accessible :funding_id, :investor_id, :investor_perma

  belongs_to :company
  belongs_to :individual
  belongs_to :financial
  belongs_to :funding


end
