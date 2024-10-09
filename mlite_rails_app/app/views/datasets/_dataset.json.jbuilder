json.extract! dataset, :id, :name, :description, :size, :columns, :n_rows, :dataset_type, :metrics, :created_at, :updated_at
json.url dataset_url(dataset, format: :json)
