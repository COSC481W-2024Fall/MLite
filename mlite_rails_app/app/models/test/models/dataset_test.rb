require "test_helper"
require "minitest/mock"

class DatasetTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    dataset = Dataset.new(name: "Test Dataset", file: fixture_file_upload('files/sample.csv', 'text/csv'))
    assert dataset.valid?
  end

  test "should not be valid without a name" do
    dataset = Dataset.new(name: nil, file: fixture_file_upload('files/sample.csv', 'text/csv'))
    assert_not dataset.valid?
    assert_includes dataset.errors[:name], "can't be blank"
  end

  test "should not be valid if file is not CSV or Excel" do
    dataset = Dataset.new(name: "Test Dataset", file: fixture_file_upload('files/sample.txt', 'text/plain'))
    assert_not dataset.valid?
    assert_includes dataset.errors[:file], "must be a CSV or Excel file"
  end

  test "should not be valid if file size is larger than 500MB" do
    dataset = Dataset.new(name: "Test Dataset")

    blob_mock = Minitest::Mock.new
    blob_mock.expect :byte_size, 600.megabytes

    file_mock = Minitest::Mock.new
    file_mock.expect :attached?, true
    file_mock.expect :blob, blob_mock

    dataset.stub :file, file_mock do
      assert_not dataset.valid?
      assert_includes dataset.errors[:file], "must be smaller than 500MB"
    end
  end

  test "should be valid if file size is smaller than 500MB" do
    dataset = Dataset.new(name: "Test Dataset")

    blob_mock = Minitest::Mock.new
    blob_mock.expect :byte_size, 300.megabytes

    file_mock = Minitest::Mock.new
    file_mock.expect :attached?, true
    file_mock.expect :blob, blob_mock

    dataset.stub :file, file_mock do
      assert dataset.valid?
    end
  end
end
