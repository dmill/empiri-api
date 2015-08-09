class AddOpenToPublications < ActiveRecord::Migration
  def change
    add_column :publications, :open, :boolean
    add_column :publications, :closed_at, :timestamp
  end
end
