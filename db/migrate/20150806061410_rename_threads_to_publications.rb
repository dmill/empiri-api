class RenameThreadsToPublications < ActiveRecord::Migration
  def change
    rename_table :threads, :publications
  end
end
