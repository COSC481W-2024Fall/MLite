class CreateDatasets < ActiveRecord::Migration[7.2]
  def change
    create_table :datasets do |t|
      t.string :name
      t.text :description
      t.integer :size
      t.integer :columns
      t.integer :n_rows
      t.string :dataset_type
      t.json :metrics

      t.timestamps
    end
  end
end
