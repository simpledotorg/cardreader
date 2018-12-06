class AddUserIdToCards < ActiveRecord::Migration[5.2]
  def change
    add_reference :facilities, :user, index: true
    add_reference :patients, :user, index: true
    add_reference :visits, :user, index: true
  end
end
