class AddOrderedInputColumnsToModels < ActiveRecord::Migration[7.2]
  def change
    add_column :models, :ordered_input_columns, :json
  end
end
