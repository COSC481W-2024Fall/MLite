class DeploymentsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_deployment, only: %i[ show edit update destroy inference do_inference ]

  # GET /deployments or /deployments.json
  def index
    @deployments = current_user.deployments.all
    @inference_result = nil # Ensure @inference_result is nil when on index
  end

  # GET /deployments/1 or /deployments/1.json
  def show
    @inference_result = nil # Ensure @inference_result is nil on show page
  end

  # GET /deployments/new
  def new
    @deployment = Deployment.new
    @models = current_user.models
    @inference_result = nil # Ensure @inference_result is nil on new page
  end

  # GET /deployments/1/edit
  def edit
    @models = current_user.models
    @inference_result = nil # Ensure @inference_result is nil on edit page
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

  # GET /deployments/:id/inference
  def inference
    @inference_result = nil # Ensure the form starts fresh without an old inference result
  end

  # POST /deployments/:id/inference
  def do_inference
    dummy_field_1 = params[:dummy_field_1]
    dummy_field_2 = params[:dummy_field_2]
    dummy_field_3 = params[:dummy_field_3]
    dummy_field_4 = params[:dummy_field_4]

    # Generate a dummy response message
    @inference_result = "Based on your input of #{dummy_field_1}, #{dummy_field_2}, #{dummy_field_3}, and  #{dummy_field_4}, here's a dummy result."

    # Render the inference page with the result
    render :inference
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
end
