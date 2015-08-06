class RenameReviewsThreadIdColumnToPublicationId < ActiveRecord::Migration
  def change
    rename_column :reviews, :thread_id, :publication_id
  end
end
