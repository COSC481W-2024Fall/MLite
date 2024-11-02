require "test_helper"

class DatasetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @dataset = datasets(:one)
    sign_in @dataset.user
    @controller = DatasetsController.new
  end

  test "should get index" do
    get datasets_url
    assert_response :success
  end

  test "should get new" do
    get new_dataset_url
    assert_response :success
  end

  test "should create dataset" do
    assert_difference("Dataset.count") do
      post datasets_url, params: {
        dataset: {
          name: "Sample Dataset",
          user_id: @dataset.user.id,
          file: fixture_file_upload('test/fixtures/files/sample.csv', 'text/csv')
        }
      }
    end

    dataset = Dataset.last
    assert dataset.file.attached?, "File should be attached"
  end

  test "should show dataset" do
    get dataset_url(@dataset)
    assert_response :success
  end

  test "should get edit" do
    get edit_dataset_url(@dataset)
    assert_response :success
  end

  test "should update dataset" do
    patch dataset_url(@dataset), params: { dataset: { description: @dataset.description, name: @dataset.name }}
    assert_redirected_to dataset_url(@dataset)
  end

  test "should destroy dataset" do
    assert_difference("Dataset.count", -1) do
      delete dataset_url(@dataset)
    end

    assert_redirected_to datasets_url
  end

  # Test infer_dtype method
  test "should infer boolean data type" do
    values = ["true", "false", "true", "false"]
    assert_equal "boolean", @controller.send(:infer_dtype, values)
  end

  test "should infer integer data type" do
    values = ["1", "2", "3", "4"]
    assert_equal "integer", @controller.send(:infer_dtype, values)
  end

  test "should infer float data type" do
    values = ["1.0", "2.0", "3.0", "4.0"]
    assert_equal "float", @controller.send(:infer_dtype, values)
  end

  test "should infer categorical data type" do
    values = ["cat", "dog", "fish", "bird"]
    assert_equal "categorical", @controller.send(:infer_dtype, values)
  end

  # Test boolean_column? method
  test "should return true for boolean column" do
    values = ["true", "false", "true", "false"]
    assert @controller.send(:boolean_column?, values)
  end

  test "should return false for non-boolean column" do
    values = ["yes", "no", "maybe"]
    assert_not @controller.send(:boolean_column?, values)
  end

  # Test numeric_column? method
  test "should return true for numeric column" do
    values = ["1", "2", "3", "4"]
    assert @controller.send(:numeric_column?, values)
  end

  test "should return false for non-numeric column" do
    values = ["one", "two", "three"]
    assert_not @controller.send(:numeric_column?, values)
  end

  test "should correctly calculate metrics for numeric columns" do
    # Prepare simple CSV data with just one numeric column
    csv_content = <<~CSV
    name,age
    John,10
    Jane,20
    Doe,30
  CSV

    # Parse the CSV content as it would be in the controller
    csv_data = CSV.parse(csv_content, headers: true)

    # Call the private calculate_metrics method using send
    metrics = @controller.send(:calculate_metrics, csv_data)

    # Assertions for the 'age' column
    age_metrics = metrics["age"]
    assert_equal 20, age_metrics[:mean], "Mean for 'age' should be 20"
    assert_equal 10, age_metrics[:min], "Minimum 'age' should be 10"
    assert_equal 30, age_metrics[:max], "Maximum 'age' should be 30"
    assert_equal 20, age_metrics[:median], "Median for 'age' should be 20"
    assert_in_delta 8.16, age_metrics[:std_dev], 0.01, "Std Dev for 'age' should be close to 8.16"
  end

end
