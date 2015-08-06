class RenameReviewsPublicationIdToReviewableId < ActiveRecord::Migration
  def change
    rename_column :reviews, :publication_id, :reviewable_id
  end
end
