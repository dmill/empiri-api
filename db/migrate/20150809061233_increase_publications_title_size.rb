class IncreasePublicationsTitleSize < ActiveRecord::Migration
  def change
    change_column :publications, :title, :string, limit: 500
  end
end
