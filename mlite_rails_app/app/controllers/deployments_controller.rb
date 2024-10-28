class DeploymentsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_deployment, only: %i[ show edit update destroy ]

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
    # Manually set name from form input
    name = deployment_params[:name]

    # Generate default values for status and deployment_link
    status = "pending" # Set default status
    deployment_link = "https://deployments.example.com/#{name.parameterize}" # Generate deployment link

    # Create new Deployment object with the generated values
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
