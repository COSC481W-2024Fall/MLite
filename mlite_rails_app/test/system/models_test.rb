require "application_system_test_case"

class ModelsTest < ApplicationSystemTestCase
  setup do
    @model = models(:one)
  end

  test "visiting the index" do
    visit models_url
    assert_selector "h1", text: "Models"
  end

  test "should create model" do
    visit models_url
    click_on "New model"

    fill_in "Description", with: @model.description
    fill_in "Features", with: @model.features
    fill_in "Hyperparams", with: @model.hyperparams
    fill_in "Labels", with: @model.labels
    fill_in "Metrics", with: @model.metrics
    fill_in "Model type", with: @model.model_type
    fill_in "Name", with: @model.name
    fill_in "Size", with: @model.size
    fill_in "Status", with: @model.status
    fill_in "Training job", with: @model.training_job
    click_on "Create Model"

    assert_text "Model was successfully created"
    click_on "Back"
  end

  test "should update Model" do
    visit model_url(@model)
    click_on "Edit this model", match: :first

    fill_in "Description", with: @model.description
    fill_in "Features", with: @model.features
    fill_in "Hyperparams", with: @model.hyperparams
    fill_in "Labels", with: @model.labels
    fill_in "Metrics", with: @model.metrics
    fill_in "Model type", with: @model.model_type
    fill_in "Name", with: @model.name
    fill_in "Size", with: @model.size
    fill_in "Status", with: @model.status
    fill_in "Training job", with: @model.training_job
    click_on "Update Model"

    assert_text "Model was successfully updated"
    click_on "Back"
  end

  test "should destroy Model" do
    visit model_url(@model)
    click_on "Destroy this model", match: :first

    assert_text "Model was successfully destroyed"
  end
end
