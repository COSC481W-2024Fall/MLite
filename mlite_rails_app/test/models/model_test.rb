require "test_helper"
require "minitest/mock"

class ModelTest < ActiveSupport::TestCase
  test "should be valid with valid attributes" do
    model = Model.new(name: "Test Model", model_type: "decision_tree")
    assert model.valid?
  end

  test "should not be valid without a name" do
    model = Model.new(name: nil, model_type: "decision_tree")
    assert_not model.valid?
  end

  test "should not be valid if the file size is larger than 500MB" do
    model = Model.new(name: "Test Model", model_type: "decision_tree")

    # Using Minitest::Mock to mock the attached file's blob and file size
    blob_mock = Minitest::Mock.new
    blob_mock.expect :byte_size, 600.megabytes

    file_mock = Minitest::Mock.new
    file_mock.expect :attached?, true
    file_mock.expect :blob, blob_mock

    # Mock the file and blob methods
    model.stub :file, file_mock do
      assert_not model.valid?
      assert_includes model.errors[:file], "File size cannot be greater than 500MB"
    end
  end

  test "should be valid if the file size is less than 500MB" do
    model = Model.new(name: "Test Model", model_type: "decision_tree")

    # Using Minitest::Mock to mock the attached file's blob and file size
    blob_mock = Minitest::Mock.new
    blob_mock.expect :byte_size, 300.megabytes

    file_mock = Minitest::Mock.new
    file_mock.expect :attached?, true
    file_mock.expect :blob, blob_mock

    # Mock the file and blob methods
    model.stub :file, file_mock do
      assert model.valid?
    end
  end

  test "should change status to deployed" do
    model = Model.create(name: "Test Model", model_type: "decision_tree", status: "training")
    model.update(status: "deployed")
    assert_equal "deployed", model.status
  end
end

