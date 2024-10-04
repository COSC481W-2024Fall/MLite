class CreateDeployments < ActiveRecord::Migration[7.2]
  def change
    create_table :deployments do |t|
      t.string :name
      t.string :status
      t.string :deployment_link

      t.timestamps
    end
  end
end
