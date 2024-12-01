require 'httparty'
require 'socket'

class DeploymentClient
  include HTTParty

  @@base_uri = nil
  @@deployment_server_auth_token = ENV['DEPLOYMENT_SERVER_AUTH_TOKEN']

  def self.configure
    host = ENV['DEPLOYMENT_SERVER_HOST'] || 'localhost'
    port = ENV['DEPLOYMENT_SERVER_PORT'] || '5002'
    @@base_uri = "#{host == 'localhost' ? 'http://localhost' : host}#{port ? ':' + port : ''}"
  end

  def self.base_uri
    configure unless @@base_uri
    @@base_uri
  end

  def self.deployment_server_auth_token
    @@deployment_server_auth_token
  end

  def self.server_reachable?
    host = ENV['DEPLOYMENT_SERVER_HOST']&.sub(%r{^https?://}, '') || 'localhost'
    port = (ENV['DEPLOYMENT_SERVER_PORT'] || '5002').to_i
    begin
      Socket.tcp(host, port, connect_timeout: 2) {} # Try to open a TCP connection
      true
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError
      false
    end
  end

  # POST /set_model
  def self.set_model(deployment_id, model_s3_key, filename)
    return unless server_reachable?

    response = post("#{base_uri}/set_model", {
      body: { deployment_id: deployment_id, model_s3_key: model_s3_key, filename: filename, auth_token: @@deployment_server_auth_token }.to_json,
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
  def self.inference(deployment_id, input)
    return unless server_reachable?

    response = get("#{base_uri}/inference", {
      query: { deployment_id: deployment_id, model_input: input.to_json, auth_token: @@deployment_server_auth_token }
    })

    if response.success?
      puts "Inference result: #{response.body}"
    else
      puts "Error during inference: #{response.body}"
    end
    response
  end
end