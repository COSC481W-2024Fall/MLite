class AddModelToDeployments < ActiveRecord::Migration[7.2]
  def change
    add_reference :deployments, :model, foreign_key: true
  end
end
