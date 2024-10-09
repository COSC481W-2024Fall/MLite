class CreateModels < ActiveRecord::Migration[7.2]
  def change
    create_table :models do |t|
      t.string :name
      t.text :description
      t.integer :size
      t.json :features
      t.json :labels
      t.string :model_type
      t.json :hyperparams
      t.string :status
      t.string :training_job
      t.json :metrics

      t.timestamps
    end
  end
end
