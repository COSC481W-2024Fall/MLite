require "test_helper"

class DeploymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @deployment = deployments(:one)
    @model = @deployment.model
    @dataset = @model.dataset
    sign_in @dataset.user
  end

  test "should get index" do
    get deployments_url
    assert_response :success
  end

  test "should get new" do
    get new_deployment_url
    assert_response :success
  end

  test "should create deployment" do
    assert_difference("Deployment.count") do
      post deployments_url, params: { deployment: { deployment_link: @deployment.deployment_link, name: @deployment.name, status: @deployment.status, model_id: @model.id } }
    end

    assert_redirected_to deployment_url(Deployment.last)
  end

  test "should show deployment" do
    get deployment_url(@deployment)
    assert_response :success
  end

  test "should get edit" do
    get edit_deployment_url(@deployment)
    assert_response :success
  end

  test "should update deployment" do
    patch deployment_url(@deployment), params: { deployment: { deployment_link: @deployment.deployment_link, name: @deployment.name, status: @deployment.status } }
    assert_redirected_to deployment_url(@deployment)
  end

  test "should destroy deployment" do
    assert_difference("Deployment.count", -1) do
      delete deployment_url(@deployment)
    end

    assert_redirected_to deployments_url
  end

  # Inference Tests
  test "should get inference page" do
    get deployment_inference_path(@deployment)
    assert_response :success
    assert_select "h1", "Run Inference for Deployment" # Check for page title
  end

  test "should post do_inference and display result" do
    post deployment_inference_path(@deployment), params: {
      dummy_field_1: 25,
      dummy_field_2: 5.8,
      dummy_field_3: "yes",
      dummy_field_4: "green"
    }
    assert_response :success
    assert_select "h2", "Inference Result"
    assert_select "p", /Based on your input of 25, 5.8, yes, and green, here's a dummy result./
  end

  test "should validate inference form fields" do
    # Simulate submitting without filling out required fields
    post deployment_inference_path(@deployment), params: {
      dummy_field_1: "",
      dummy_field_2: "",
      dummy_field_3: "",
      dummy_field_4: ""
    }
    assert_response :success
    assert_select "h2", false, "Expected no inference result due to missing fields"
  end
end
