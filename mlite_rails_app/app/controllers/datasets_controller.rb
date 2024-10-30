require 'csv'

class DatasetsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_dataset, only: %i[show edit update destroy]

  # GET /datasets or /datasets.json
  def index
    @datasets = current_user.datasets.all
  end

  # GET /datasets/1 or /datasets/1.json
  def show
    result = read_dataset_content(@dataset)
    @dataset_content = result[:content]
    @limited = result[:limited]
  end

  # GET /datasets/new
  def new
    @dataset = current_user.datasets.new
  end

  # GET /datasets/1/edit
  def edit
  end

  # POST /datasets or /datasets.json
  def create
    @dataset = current_user.datasets.new(dataset_params.merge(dataset_type: dataset_params[:dataset_type] || "csv"))

    if @dataset.save
      redirect_to @dataset, notice: "Dataset was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /datasets/1 or /datasets/1.json
  def update
    if @dataset.update(dataset_params)
      redirect_to @dataset, notice: "Dataset was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /datasets/1 or /datasets/1.json
  def destroy
    @dataset.destroy!

    redirect_to datasets_path, status: :see_other, notice: "Dataset was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dataset
    @dataset = current_user.datasets.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def dataset_params
    params.require(:dataset).permit(:name, :description, :file, :size, :columns, :n_rows, :dataset_type, :metrics) # exclude :user_id
  end

  # Method to read and parse the CSV content
  def read_dataset_content(dataset)
    # Download and parse CSV content
    csv_content = dataset.file.download
    parsed_content = CSV.parse(csv_content, headers: true)

    # Store the original headers
    headers = parsed_content.headers

    # Limit the rows displayed: first 20 and last 10 if more than 30 rows
    if parsed_content.size > 30
      # Convert to array to manipulate rows
      rows = parsed_content.to_a
      limited_rows = rows.first(20) + rows.last(10)
      limited = true
    else
      limited_rows = parsed_content.to_a
      limited = false
    end

    # Create a new CSV::Table with limited rows while preserving the headers
    dataset_content = CSV::Table.new(limited_rows.map { |row| CSV::Row.new(headers, row) })

    { content: dataset_content, limited: limited }
  end



end
