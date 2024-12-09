class ModelsController < ApplicationController
  skip_forgery_protection only: :upload_file

  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_model, only: %i[ show edit update destroy]
  skip_before_action :authenticate_user!, only: :upload_file

  # GET /models or /models.json
  def index
    @models = current_user.models.order(created_at: :desc)
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
    assign_variables_for_new
  end

  # GET /models/1/edit
  def edit
    @datasets = current_user.datasets
  end

  # POST /models or /models.json
  def create
    selected_model_index = params[:model][:selected_model]

    if selected_model_index.nil? || params[:recommended_models][selected_model_index].nil?
      @model = Model.new(model_params) # Initialize model with any provided data
      assign_variables_for_new
      flash.now[:alert] = "You must select a recommended model before proceeding."
      render :new, status: :unprocessable_entity and return
    end
    model_type = params[:recommended_models][selected_model_index][:model_type]
    hyperparams = JSON.parse(params[:recommended_models][selected_model_index][:hyperparams])
    @columns = ['iris_width', 'iris_length', 'iris_species'] # hardcoded for now

    @model = Model.new(
      name: model_params[:name],
      description: model_params[:description],
      dataset_id: model_params[:dataset_id],
      model_type: model_type,
      hyperparams: hyperparams,
      features: @columns - [params[:selected_column]],
      labels: [params[:selected_column]],
      status: 'queued'
    )

    if @model.save
      sqs_messenger = SqsMessageSender.send_training_request({
        model: @model.as_json,
        dataset_s3_key: @model.dataset.file.key
      }) # schedule training job
      redirect_to models_path, notice: "Model was successfully created."
    else
      assign_variables_for_new
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /models/1 or /models/1.json
  def update
    if @model.update(model_params)
      redirect_to models_path, notice: "Model was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /models/1 or /models/1.json
  def destroy
    @model.destroy!

    redirect_to models_path, notice: "Model was successfully destroyed."
  end

  def upload_file
    if params['auth_token'] != ENV["UPLOAD_AUTH_TOKEN"]
      render json: { error: "Invalid auth token" }, status: :unauthorized and return
    end

    @model = Model.find(params[:id])
    if params[:file].present?
      @model.file.attach(params[:file]) # Attach the uploaded file to the model
      @model.update(status: 'trained')
      render json: { message: "File uploaded successfully", model: @model }, status: :ok
    else
      render json: { error: "No file provided" }, status: :unprocessable_entity
    end
  end

  private

    def assign_variables_for_new
      @datasets = current_user.datasets
      if params.dig(:model, :dataset_id) || params[:dataset_id]
        @dataset = current_user.datasets.find(params.dig(:model, :dataset_id) || params[:dataset_id])
        @columns = @dataset.columns.map { |column| column["name"] }
      end
      @selected_column = params[:selected_column]
      if @selected_column
        @recommended_models = generate_model_recommendations(@dataset, @selected_column)
      end
    end
    def generate_model_recommendations(dataset, selected_column)
      # TODO: hardcoded for now
      recommender = ModelRecommender.new(dataset)
      recommender.recommend_model(
        [selected_column],
        @columns - [selected_column]
      )
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_model
      @model = current_user.models.find(params[:id])
      @dataset = @model.dataset
    end

    # Only allow a list of trusted parameters through.
    def model_params
      params.require(:model).permit(:name, :description, :dataset_id)
    end
end
