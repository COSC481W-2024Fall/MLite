require 'csv'

class DatasetsController < ApplicationController
  before_action :authenticate_user!, unless: -> { Rails.env.test? }
  before_action :set_dataset, only: %i[ show edit update destroy ]

  # GET /datasets or /datasets.json
  def index
    @datasets = current_user.datasets.all
  end

  # GET /datasets/1 or /datasets/1.json
  def show
    # Read the dataset's file content
    @dataset_content = read_dataset_content(@dataset)
    preview_result = read_dataset_content_for_preview(@dataset)
    @first_content = preview_result[:first_content]
    @last_content = preview_result[:last_content]
    @limited = preview_result[:limited]
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

  # Use callbacks to share common setup or constraints between actions.
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
    elsif values.all? { |v| v.match?(/\A-?(?:\d+|\.\d+|\d+\.\d+)\z/) }
      "float"
    else
      "categorical"
    end
  end

  # Method to read and parse the CSV content
  def read_dataset_content_for_preview(dataset)
    # Download and parse CSV content
    csv_content = dataset.file.download
    parsed_content = CSV.parse(csv_content, headers: true)

    # Store the original headers
    headers = parsed_content.headers

    # Limit the rows displayed: first 20 and last 10 if more than 30 rows
    if parsed_content.size > 30
      # Convert to array to manipulate rows
      rows = parsed_content.to_a
      first_rows = rows.first(21)
      last_rows = rows.last(10)
      limited = true
    else
      first_rows = parsed_content.to_a
      last_rows = []
      limited = false
    end

    # Create two new CSV::Tables with limited rows while preserving the headers
    first_table_content = CSV::Table.new(first_rows.map { |row| CSV::Row.new(headers, row) })
    last_table_content = CSV::Table.new(last_rows.map { |row| CSV::Row.new(headers, row) })

    { first_content: first_table_content, last_content: last_table_content, limited: limited }
  end

  # Helper method to check if a column contains boolean values
  def boolean_column?(values)
    boolean_patterns = %w[true false yes no 0 1]
    values.all? { |v| boolean_patterns.include?(v.downcase) }
  end

  # Helper method to detect if a column is categorical
  def categorical?(values)
    unique_values = values.uniq

    # A column is categorical if it has fewer unique values than the threshold
    unique_values.size < threshold
  end



  def calculate_metrics(csv_data)
    metrics = {}

    # Loop through each column and process numeric or categorical data
    csv_data.headers.each do |column|
      values = csv_data[column].compact

      if numeric_column?(values)
        # Numeric data: calculate mean, min, max, median, and std_dev
        numeric_values = values.map(&:to_f)
        metrics[column] = {
          mean: (numeric_values.sum / numeric_values.size).round(2),
          min: numeric_values.min,
          max: numeric_values.max,
          median: numeric_values.sort[numeric_values.size / 2],
          std_dev: Math.sqrt(numeric_values.sum { |v| (v - numeric_values.sum / numeric_values.size)**2 } / numeric_values.size).round(2)
        }
      else
        if not boolean_column?(values)
          # Categorical metrics
          unique_counts = values.tally
          total_values = values.size
          mode = unique_counts.max_by { |_, count| count }&.first

          # Calculate entropy
          entropy = -unique_counts.values.map { |count| count.to_f / total_values * Math.log2(count.to_f / total_values) }.sum.round(2)

          # Calculate diversity index (Simpson's Diversity Index)
          diversity_index = 1 - unique_counts.values.map { |count| (count.to_f / total_values)**2 }.sum.round(2)

          metrics[column] = {
            mode: mode,
            unique_count: unique_counts.keys.size,
            frequency_distribution: unique_counts,
            top_categories: unique_counts.sort_by { |_, count| -count }.first(3).to_h, # Top 3 categories
            entropy: entropy,
            diversity_index: diversity_index,
            category_percentages: unique_counts.transform_values { |count| (count.to_f / total_values * 100).round(2) },
            least_frequent_category: unique_counts.min_by { |_, count| count }&.first,
            null_count: csv_data[column].size - total_values # Count of missing/null values
          }
          end
        end
      end

      metrics
    end

  # Helper method to check if a column contains only numeric data (integer or float)
  def numeric_column?(values)
    values.all? { |v| v.match?(/\A-?(?:\d+|\.\d+|\d+\.\d+)\z/) }
  end


end
