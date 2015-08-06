class AddDefaultToExperimentsSubmitted < ActiveRecord::Migration
  def change
    change_column :experiments, :submitted, :boolean, default: false
  end
end
