class AddCreatedAtAndUpdatedAtToThreads < ActiveRecord::Migration
  def change
    add_column :threads, :created_at, :timestamp
    add_column :threads, :updated_at, :timestamp
  end
end
