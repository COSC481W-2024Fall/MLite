require "test_helper"
require "minitest/mock"
# require "rails_helper"



class DatasetTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    dataset = Dataset.new(
      name: "Test Dataset",
      description: "A sample dataset",
      dataset_type: "csv",
      file: nil, # Assuming file is attached later in a real scenario
      size: 100.megabytes,
      columns: 10,
      n_rows: 1000,
      metrics: {}
    )
    assert dataset.valid?
  end

  test "should not be valid without a name" do
    dataset = Dataset.new(
      name: nil,
      description: "A sample dataset",
      dataset_type: "csv",
      file: nil,
      size: 100.megabytes,
      columns: 10,
      n_rows: 1000,
      metrics: {}
    )
    assert_not dataset.valid?
  end

  test "should not be valid without a dataset_type" do
    dataset = Dataset.new(
      name: "Test Dataset",
      description: "A sample dataset",
      dataset_type: nil, # Ensures we are testing the missing dataset_type case
      file: nil,
      size: 100.megabytes,
      columns: 10,
      n_rows: 1000,
      metrics: {}
    )
    assert_not dataset.valid?
  end

  test "should not be valid if the file size is larger than 500MB" do
    dataset = Dataset.new(name: "Test Dataset", dataset_type: "csv")

    file_mock = Minitest::Mock.new
    file_mock.expect :attached?, true
    file_mock.expect :attached?, true
    file_mock.expect :byte_size, 600.megabytes
    file_mock.expect :content_type, "text/csv"

    dataset.stub :file, file_mock do
      assert dataset.valid? == false
    end
  end

  test "should be valid if the file size is less than 500MB" do
    dataset = Dataset.new(name: "Test Dataset", dataset_type: "csv")

    file_mock = Minitest::Mock.new
    file_mock.expect :attached?, true
    file_mock.expect :attached?, true
    file_mock.expect :byte_size, 300.megabytes
    file_mock.expect :content_type, "text/csv"

    dataset.stub :file, file_mock do
      assert dataset.valid?
    end
  end

  test "should create a dataset successfully" do
    dataset = Dataset.create(
      name: "New Dataset",
      description: "A new dataset for testing",
      dataset_type: "csv",
      size: 250.megabytes,
      columns: 5,
      n_rows: 500,
      metrics: {}
    )
    assert dataset.persisted?
  end
end
