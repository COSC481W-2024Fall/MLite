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

    respond_to do |format|
      if @model.save
        format.html { redirect_to model_url(@model), notice: "Model was successfully created." }
        format.json { render :show, status: :created, location: @model }
      else
        @datasets = current_user.datasets
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /models/1 or /models/1.json
  def update
    respond_to do |format|
      if @model.update(model_params)
        format.html { redirect_to model_url(@model), notice: "Model was successfully updated." }
        format.json { render :show, status: :ok, location: @model }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @model.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /models/1 or /models/1.json
  def destroy
    @model.destroy!

    respond_to do |format|
      format.html { redirect_to models_url, notice: "Model was successfully destroyed." }
      format.json { head :no_content }
    end
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
