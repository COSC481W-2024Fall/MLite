json.extract! deployment, :id, :name, :status, :deployment_link, :created_at, :updated_at
json.url deployment_url(deployment, format: :json)
