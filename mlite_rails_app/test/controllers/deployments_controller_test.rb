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
end