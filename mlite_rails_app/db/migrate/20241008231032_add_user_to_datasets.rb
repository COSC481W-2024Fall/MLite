class AddUserToDatasets < ActiveRecord::Migration[7.2]
  def change
    add_reference :datasets, :user, foreign_key: true
  end
end