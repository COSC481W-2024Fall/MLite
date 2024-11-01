require "test_helper"
require "csv"

class DatasetsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @dataset = datasets(:one)
    sign_in @dataset.user
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
      post datasets_url, params: { dataset: { description: @dataset.description, name: @dataset.name } }
    end

    assert_redirected_to dataset_url(Dataset.last)
  end


  test "should show dataset with less than or equal to 30 rows" do
    # Create a mock CSV file with 30 rows
    csv_content = CSV.generate(headers: true) do |csv|
      csv << ["column1", "column2"]
      30.times { csv << ["data1", "data2"] }
    end
    @dataset.file.attach(io: StringIO.new(csv_content), filename: "test.csv", content_type: "text/csv")

    get dataset_url(@dataset)
    assert_response :success

    # Assert full dataset table is displayed
    assert_select "h3", text: "Full Dataset"
    assert_select "table", 1
    assert_select "tr", count: 31 # 1 header row + 30 data rows
  end

  test "should show dataset with more than 30 rows" do
    # Create a mock CSV file with 40 rows
    csv_content = CSV.generate(headers: true) do |csv|
      csv << ["column1", "column2"]
      40.times { csv << ["data1", "data2"] }
    end
    @dataset.file.attach(io: StringIO.new(csv_content), filename: "test.csv", content_type: "text/csv")

    get dataset_url(@dataset)
    assert_response :success

    # Assert two separate tables for first 20 and last 10 rows
    assert_select "p", text: /Showing the first 20 and last 10 rows/
    assert_select "h3", text: "First 20 Rows"
    assert_select "h3", text: "Last 10 Rows"
    assert_select "table", 2
    assert_select "tr", count: 32 # 1 header row + 20 rows in first table + 1 header row + 10 rows in last table
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
end