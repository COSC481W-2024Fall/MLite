class ModelsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_model, only: %i[ show edit update destroy ]

  # GET /models or /models.json
  def index
    @models = current_user.models.all
  end

  # GET /models/1 or /models/1.json
  def show
  end

  def deploy
    @model = Model.find(params[:id])
    @model.update(status: 'deployed')
    redirect_to @model, notice: "Model has been successfully deployed."
  end


  # GET /models/new
  def new
    @model = Model.new
    @datasets = current_user.datasets
  end

  # GET /models/1/edit
  def edit
    @datasets = current_user.datasets
  end

  # POST /models or /models.json
  def create
    @model = Model.new(model_params)

    if @model.save
      redirect_to model_path(@model), notice: "Model was successfully created."
    else
      @datasets = current_user.datasets
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /models/1 or /models/1.json
  def update
    if @model.update(model_params)
      redirect_to model_path(@model), notice: "Model was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /models/1 or /models/1.json
  def destroy
    @model.destroy!

    redirect_to models_path, notice: "Model was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_model
      @model = current_user.models.find(params[:id])
      @dataset = @model.dataset
    end

    # Only allow a list of trusted parameters through.
    def model_params
      params.require(:model).permit(:name, :description, :size, :features, :labels, :model_type, :hyperparams, :status, :training_job, :metrics, :file, :dataset_id)
    end
end
