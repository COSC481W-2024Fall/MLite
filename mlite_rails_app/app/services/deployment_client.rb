require 'httparty'

class DeploymentClient
  include HTTParty

  def initialize(base_uri)
    @base_uri = base_uri # Instance variable for the base URI
  end

  def self.deploy(deployment)
  end

  # POST /set_model
  def set_model(deployment_id, model_s3_key, filename)
    response = self.class.post("#{@base_uri}/set_model", {
      body: { deployment_id: deployment_id, model_s3_key: model_s3_key, filename: filename }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    })

    if response.success?
      puts "Model loaded successfully: #{response.body}"
    else
      puts "Error loading model: #{response.body}"
    end
    response
  end

  # GET /inference
  def inference(input)
    response = self.class.get("#{@base_uri}/inference", {
      query: { model_input: input.to_json }
    })

    if response.success?
      puts "Inference result: #{response.body}"
    else
      puts "Error during inference: #{response.body}"
    end
    response
  end
end