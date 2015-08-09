class ChangePublicationsOpenToClosed < ActiveRecord::Migration
  def change
    rename_column :publications, :open, :closed
    change_column :publications, :closed, :boolean, default: false
  end
end
