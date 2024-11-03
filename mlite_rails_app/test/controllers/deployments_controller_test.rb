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

    # Check if the fields are dynamically generated
    DeploymentsController::COLUMNS.each do |column|
      assert_select "input[name=?]", column[:name] if column[:dtype] != "categorical"
      assert_select "select[name=?]", column[:name] if column[:dtype] == "categorical"
    end
  end

  test "should post do_inference and redirect to inference result" do
    # Prepare dynamic params based on the columns defined in COLUMNS
    params = DeploymentsController::COLUMNS.each_with_object({}) do |column, hash|
      case column[:dtype]
      when "int"
        hash[column[:name]] = 25
      when "float"
        hash[column[:name]] = 5.8
      when "bool"
        hash[column[:name]] = "yes"
      when "categorical"
        hash[column[:name]] = column[:values].first
      end
    end

    post deployment_inference_path(@deployment), params: params

    # Check that the response is a redirect
    assert_response :redirect
    follow_redirect!

    # Check that the redirected path matches the expected path
    expected_path = deployment_inference_result_path(@deployment)
    assert_equal expected_path, path

    # Check for the inference result in the redirected response
    assert_match /Based on your input of/, @response.body
  end



  test "should get inference result page" do
    # Simulate posting the inference values
    params = DeploymentsController::COLUMNS.each_with_object({}) do |column, hash|
      hash[column[:name]] = column[:name] == "has_car" ? "yes" : 25
    end

    post deployment_inference_path(@deployment), params: params

    # Follow the redirect to the inference result
    follow_redirect!

    # Check for the response and content in the inference result page
    assert_response :success
    assert_select "h1", "Inference Result" # Check for title
    assert_select "p", /Based on your input of/ # Check for inference result message
  end
end
