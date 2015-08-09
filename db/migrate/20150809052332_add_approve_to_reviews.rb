class AddApproveToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :approve, :boolean
  end
end
