

class ModelRecommender
  # Assuming `dataset` is a hash with feature names as keys and array of values as the values.
  attr_reader :dataset

  def initialize(dataset)
    @dataset_record = dataset
    @dataset = dataset.parse_csv_to_hash
  end
  def recommend_model(columns, features) # columns: target column (Y), features: feature columns (X)
    # Extract and encode data for features (X) and target column (y)
    x = features.map { |feature| encode_feature(dataset[feature], feature) }
    y = encode_feature(dataset[columns.first], columns.first) # Assuming single column target for simplicity

    # Calculate linearity (R² score)
    coefficients = least_squares_solution(x, y)
    y_pred = predict(x, coefficients)
    r2 = calculate_r2(y, y_pred)

    # Model recommendation based on R² score and data characteristics
    if ['float', 'integer'].include?(column_type(columns.first))
      [
        { model_type: "linear_regression", hyperparams: { regularization: "l2" } },
        # { model_type: "neural_network_regression", hyperparams: { iterations: 300} },
      ]
    else
      [
        { model_type: "logistic_regression", hyperparams: { regularization: "l2" } },
        { model_type: "decision_tree", hyperparams: { max_depth: 5 } },
        { model_type: "svm", hyperparams: { kernel: "rbf", C: 1.0 } },
        # { model_type: "neural_network_classifier", hyperparams: { iterations: 300 } }
      ]
    end
    # if r2 > 0.7
    #   [{ model_type: "linear_regression", hyperparams: { regularization: "l2" } }]
    # elsif y.uniq.size == 2
    #   [{ model_type: "logistic_regression", hyperparams: { regularization: "l2" } }]
    # elsif x.first.size > 10
    #   [{ model_type: "decision_tree", hyperparams: { max_depth: 5 } }]
    # else
    #   [{ model_type: "svm", hyperparams: { kernel: "rbf", C: 1.0 } }]
    # end
  end

  private

  # Encode feature if it is categorical, otherwise return as is
  def encode_feature(values, feature_name)
    if column_type(feature_name) == "categorical"
      encode_categorical(values)
    elsif column_type(feature_name) == "boolean"
      values.map { |v| v ? 1 : 0 }
    else
      values.map(&:to_f) # Convert to float for numerical columns
    end
  end

  # Helper to encode categorical values
  def encode_categorical(values)
    unique_values = values.uniq
    encoding_map = unique_values.each_with_index.to_h # Map each unique value to an integer
    values.map { |value| encoding_map[value] }
  end

  # Helper to determine column type
  def column_type(feature_name)
    @dataset_record.columns.find { |col| col["name"] == feature_name }["dtype"]
  end

  # Calculate the least squares solution
  def least_squares_solution(x, y)
    x_matrix = Numo::NArray[*x.transpose]
    y_vector = Numo::NArray[*y]
    (x_matrix.transpose.dot(x_matrix)).dot(x_matrix.transpose).dot(y_vector)
  end

  # Predict based on coefficients
  def predict(x, coefficients)
    x.transpose.map { |x_row| x_row.zip(coefficients).map { |xi, ci| xi * ci }.sum }
  end

  # Calculate R² score
  def calculate_r2(y, y_pred)
    y_mean = y.sum.to_f / y.size
    ss_tot = y.map { |yi| (yi - y_mean)**2 }.sum
    ss_res = y.zip(y_pred).map { |yi, ypi| (yi - ypi)**2 }.sum
    1 - (ss_res / ss_tot)
  end
end