class ChangeInvestmentTable < ActiveRecord::Migration
  def change

    add_column :investments, :company_perma, :string
    add_column :investments, :company_id, :integer
    add_column :investments, :financial_perma, :string
    add_column :investments, :financial_id, :integer
    add_column :investments, :individual_perma, :string
    add_column :investments, :individual_id, :integer
    remove_column :investments, :investor_id
    remove_column :investments, :investor_perma

  end
end
