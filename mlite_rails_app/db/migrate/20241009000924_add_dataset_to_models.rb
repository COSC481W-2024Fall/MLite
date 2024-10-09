class AddDatasetToModels < ActiveRecord::Migration[7.2]
  def change
    add_reference :models, :dataset, foreign_key: true
  end
end
