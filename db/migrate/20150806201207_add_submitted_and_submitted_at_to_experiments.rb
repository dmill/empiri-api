class AddSubmittedAndSubmittedAtToExperiments < ActiveRecord::Migration
  def change
    add_column :experiments, :submitted, :boolean
    add_column :experiments, :submitted_at, :timestamp
  end
end
