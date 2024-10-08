require "test_helper"

class DeploymentTest < ActiveSupport::TestCase
  # Test that a valid deployment is saved correctly
  test "should save valid deployment" do
    deployment = Deployment.new(name: "Test Deployment", status: "pending", deployment_link: "https://deployments.example.com/test-deployment")
    assert deployment.save, "Failed to save valid deployment"
  end

  # Test that a deployment without a name is invalid
  test "should not save deployment without name" do
    deployment = Deployment.new(status: "pending", deployment_link: "https://deployments.example.com/test-deployment")
    assert_not deployment.save, "Saved the deployment without a name"
  end

  # Test that a deployment is invalid without a status
  test "should not save deployment without status" do
    deployment = Deployment.new(name: "Test Deployment", deployment_link: "https://deployments.example.com/test-deployment")
    assert_not deployment.save, "Saved the deployment without a status"
  end

  # Test that a deployment is invalid without a deployment_link
  test "should not save deployment without deployment_link" do
    deployment = Deployment.new(name: "Test Deployment", status: "pending")
    assert_not deployment.save, "Saved the deployment without a deployment link"
  end
end
