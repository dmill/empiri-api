class RenameExperimentsThreadIdColumnToPublicationId < ActiveRecord::Migration
  def change
    rename_column :experiments, :thread_id, :publication_id
  end
end
