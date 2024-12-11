class DeploymentsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_deployment, only: %i[ show edit update destroy inference do_inference ]
  before_action :set_dataset_columns, only: %i[ inference do_inference ]

  # GET /deployments or /deployments.json
  def index
    @deployments = current_user.deployments.order(created_at: :desc)
  end

  # GET /deployments/1 or /deployments/1.json
  def show
  end

  # GET /deployments/new
  def new
    @deployment = Deployment.new
    @models = current_user.models
  end

  # GET /deployments/1/edit
  def edit
    @models = current_user.models
  end

  # POST /deployments or /deployments.json
  def create
    name = deployment_params[:name]
    status = "deployed" # Set default status
    # deployment_link = "https://deployments.example.com/#{name.parameterize}" # Generate deployment link

    @deployment = Deployment.new(
      name: name,
      status: status,
      # deployment_link: deployment_link,
      model_id: deployment_params[:model_id]
    )

    if @deployment.save
      response = DeploymentClient.set_model(@deployment.id, @deployment.model.file.key, @deployment.model.file.filename)
      unless response && response.success?
        @deployment.update(status: "error")
      end
      redirect_to deployments_path, notice: "Deployment was successfully created."
    else
      @models = current_user.models
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /deployments/1 or /deployments/1.json
  def update
    if @deployment.update(deployment_params)
      redirect_to deployments_path, notice: "Deployment was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /deployments/1 or /deployments/1.json
  def destroy
    @deployment.destroy

    redirect_to deployments_path, notice: "Deployment was successfully destroyed."
  end

  def inference
  end

  # GET /deployments/:id/inference
  def do_inference
    input_values = {}

    # Loop through columns to dynamically fetch input values
    @columns.each do |column|
      dtype = column[:dtype]
      if dtype == "float"
        value = params[column[:name]].to_f
      elsif dtype == "integer"
        value = params[column[:name]].to_i
      elsif dtype == "boolean"
        value = params[column[:name]] == "Yes" ? 1 : 0
      elsif dtype == "categorical"
        value = params[column[:name]]
      else
        raise "Unsupported data type: #{dtype}"
      end
      input_values[column[:name]] = value
    end

    ordered_input_columns = @deployment.model.ordered_input_columns

    true_columns = []

    new_input_values = []

    ordered_input_columns.each do |col|
      if input_values.has_key?(col)
        new_input_values << input_values[col]
      else
        new_input_values << 0
      end
    end

    input_values.each do |key, val|
      next if ordered_input_columns.include?(key)

      comb = "#{key}_#{val}"
      if ordered_input_columns.include?(comb)
        idx = ordered_input_columns.index(comb)
        new_input_values[idx] = 1
      end
    end

    response = DeploymentClient.inference(@deployment.id, new_input_values)

    @request_successful = response&.success?
    if @request_successful
      @result = response["result"]
    end

    # # Generate a dynamic response message based on input values
    # @inference_result = "Based on your input of #{response}, here's a dummy result."

    # Redirect to the new action, passing the deployment ID and inference result
    render turbo_stream: turbo_stream.update("inference-results", partial: "deployments/inference_results", locals: { request_successful: @request_successful, result: @result })
  end

  # GET /deployments/:id/inference_result
  def inference_result
    @deployment = current_user.deployments.find(params[:id]) # Fetch the deployment
    @inference_result = params[:inference_result]
    render :inference_result
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_deployment
    @deployment = current_user.deployments.find(params[:id])
    @model = @deployment.model
  end

  def set_dataset_columns
    # Define columns array for dynamic field generation
    @columns = @deployment.model.dataset.columns.freeze
    # Convert keys to symbols and transform "values" to an array if it's a string
    @columns = @columns.map do |col|
      col = col.transform_keys(&:to_sym)
      col[:values] = col[:values].split(", ").map(&:strip) if col[:values].is_a?(String)
      col
    end
    # remove target label from input fields
    labels = @deployment.model.labels
    @columns = @columns.select { |col| !labels.include?(col[:name]) }
  end

  # Only allow a list of trusted parameters through.
  def deployment_params
    params.require(:deployment).permit(:name, :model_id)
  end
end
