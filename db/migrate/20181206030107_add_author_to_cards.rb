class AddAuthorToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :facilities, :author_id, :integer, index: true
    add_column :patients, :author_id, :integer, index: true
    add_column :visits, :author_id, :integer, index: true

    add_foreign_key :facilities, :users, column: :author_id
    add_foreign_key :patients, :users, column: :author_id
    add_foreign_key :visits, :users, column: :author_id
  end
end
