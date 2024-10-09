json.extract! model, :id, :name, :description, :size, :features, :labels, :model_type, :hyperparams, :status, :training_job, :metrics, :created_at, :updated_at
json.url model_url(model, format: :json)
