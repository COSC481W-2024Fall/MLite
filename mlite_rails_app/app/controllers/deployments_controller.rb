class DeploymentsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_deployment, only: %i[ show edit update destroy inference do_inference ]

  # Define columns array for dynamic field generation
  COLUMNS = [
    { name: "age", dtype: "int" },
    { name: "height", dtype: "float" },
    { name: "has_car", dtype: "bool" },
    { name: "color", dtype: "categorical", values: ["blue", "red", "green"] }
  ].freeze

  # GET /deployments or /deployments.json
  def index
    @deployments = current_user.deployments.all
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
    status = "pending" # Set default status
    deployment_link = "https://deployments.example.com/#{name.parameterize}" # Generate deployment link

    @deployment = Deployment.new(
      name: name,
      status: status,
      deployment_link: deployment_link,
      model_id: deployment_params[:model_id]
    )

    if @deployment.save
      redirect_to deployment_path(@deployment), notice: "Deployment was successfully created."
    else
      @models = current_user.models
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /deployments/1 or /deployments/1.json
  def update
    if @deployment.update(deployment_params)
      redirect_to deployment_path(@deployment), notice: "Deployment was successfully updated."
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

    # Ensures @columns is set to the defined COLUMNS array
    @columns = self.class::COLUMNS
  end

  # GET /deployments/:id/inference
  def do_inference
    input_values = {}

    # Loop through columns to dynamically fetch input values
    COLUMNS.each do |column|
      input_values[column[:name]] = params[column[:name]]
    end

    # Generate a dynamic response message based on input values
    @inference_result = "Based on your input of #{input_values.values.join(', ')}, here's a dummy result."

    # Redirect to the new action, passing the deployment ID and inference result
    redirect_to deployment_inference_result_path(@deployment, inference_result: @inference_result)
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

  # Only allow a list of trusted parameters through.
  def deployment_params
    params.require(:deployment).permit(:name, :model_id)
  end

  # Only allow a list of trusted parameters through.
  def deployment_params
    params.require(:deployment).permit(:name, :model_id)
  end
end
