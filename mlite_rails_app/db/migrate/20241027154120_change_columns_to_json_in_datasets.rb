class ChangeColumnsToJsonInDatasets < ActiveRecord::Migration[7.0]
  def change
    # Set all existing values to NULL to avoid casting issues
    change_column_default :datasets, :columns, from: nil, to: []
    execute 'UPDATE datasets SET columns = NULL'

    # change the column type to JSON
    change_column :datasets, :columns, :json, using: 'columns::text::json'
  end
end



