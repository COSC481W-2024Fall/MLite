class DeploymentsController < ApplicationController
  before_action :set_deployment, only: %i[ show edit update destroy ]

  # GET /deployments or /deployments.json
  def index
    @deployments = Deployment.all
  end

  # GET /deployments/1 or /deployments/1.json
  def show
  end

  # GET /deployments/new
  def new
    @deployment = Deployment.new
  end

  # GET /deployments/1/edit
  def edit
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
      deployment_link: deployment_link
    )

    respond_to do |format|
      if @deployment.save
        format.html { redirect_to deployment_url(@deployment), notice: "Deployment was successfully created." }
        format.json { render :show, status: :created, location: @deployment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @deployment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deployments/1 or /deployments/1.json
  def update
    respond_to do |format|
      if @deployment.update(deployment_params)
        format.html { redirect_to deployment_url(@deployment), notice: "Deployment was successfully updated." }
        format.json { render :show, status: :ok, location: @deployment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deployment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deployments/1 or /deployments/1.json
  def destroy
    @deployment.destroy

    respond_to do |format|
      format.html { redirect_to deployments_url, notice: "Deployment was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_deployment
    @deployment = Deployment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def deployment_params
    params.require(:deployment).permit(:name)
  end
end
