class IncreaseExperimentsTitleSize < ActiveRecord::Migration
  def change
    change_column :experiments, :title, :string, limit: 500
  end
end
