require "test_helper"

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
end