class AddCreatedAtAndUpdatedAtToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :created_at, :timestamp
    add_column :experiments, :updated_at, :timestamp
  end
end
