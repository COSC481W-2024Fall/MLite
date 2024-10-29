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
    # Read the dataset's file content
    @dataset_content = read_dataset_content(@dataset)
  end

  def read_dataset_content(dataset)
    # Download and parse CSV content
    csv_content = dataset.file.download
    CSV.parse(csv_content, headers: true)
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

    render :new, status: :unprocessable_entity unless @dataset.save
    extract_metadata_and_metrics(@dataset) # Extract metadata after saving
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

  def set_dataset
    @dataset = current_user.datasets.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def dataset_params
    params.require(:dataset).permit(:name, :description, :file, :size, :columns, :n_rows, :dataset_type, :metrics)
  end

  def extract_metadata_and_metrics(dataset)
    # Download and parse the CSV content
    csv_content = dataset.file.download
    csv_data = CSV.parse(csv_content, headers: true)

    # Process and store only categorical columns
    columns_data = csv_data.headers.map do |header|
      values = csv_data[header].compact # Ignore nil values
      dtype = infer_dtype(values) # Infer data type

      # Only assign unique values if the column is categorical
      column_data = {
        name: header,
        dtype: dtype,
      }

      if dtype == "categorical"
        column_data[:values] = values.uniq.join(", ") # Join unique values as a string
      end

      column_data
    end.compact # Remove nil or skipped columns


    # Set dataset metadata
    dataset.size = csv_content.bytesize
    dataset.n_rows = csv_data.size
    dataset.columns = columns_data
    dataset.dataset_type = File.extname(dataset.file.filename.to_s).delete_prefix('.')
    dataset.metrics = calculate_metrics(csv_data)
  end

  # Helper method to infer data type
  def infer_dtype(values)
    # Check if all values are boolean
    if boolean_column?(values)
      "boolean"
      # Check if all values are integers
    elsif values.all? { |v| v.match?(/\A-?\d+\z/) }
      "integer"
      # Check if all values are floats
    elsif values.all? { |v| v.match?(/\A-?\d+\.\d+\z/) }
      "float"
    else
      "categorical"
    end
  end

  # Helper method to check if a column contains boolean values
  def boolean_column?(values)
    boolean_patterns = %w[true false yes no 0 1]
    values.all? { |v| boolean_patterns.include?(v.downcase) }
  end

  # Helper method to detect if a column is categorical
  def categorical?(values)
    # Define a threshold for determining categorical data
    threshold = 20  # Adjust this value as needed

    unique_values = values.uniq

    # A column is categorical if it has fewer unique values than the threshold
    unique_values.size < threshold
  end



  def calculate_metrics(csv_data)
    metrics = {}

    # Loop through each column and process only numeric data (integer or float)
    csv_data.headers.each do |column|
      values = csv_data[column].compact

      # Check if the column contains only numeric data (integer or float)
      next unless numeric_column?(values)

      # Convert values to float for metric calculations
      numeric_values = values.map(&:to_f)

      # Calculate metrics for the numeric column
      metrics[column] = {
        mean: (numeric_values.sum / numeric_values.size).round(2),
        min: numeric_values.min,
        max: numeric_values.max,
        median: numeric_values.sort[numeric_values.size / 2],
        std_dev: Math.sqrt(numeric_values.sum { |v| (v - numeric_values.sum / numeric_values.size)**2 } / numeric_values.size).round(2)
      }
    end

    metrics
  end

  # Helper method to check if a column contains only numeric data (integer or float)
  def numeric_column?(values)
    values.all? { |v| v.match?(/\A-?\d+(\.\d+)?\z/) }
  end


end
