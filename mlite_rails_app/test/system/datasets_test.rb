# test/system/datasets_test.rb
require "application_system_test_case"

class DatasetsTest < ApplicationSystemTestCase
  include Devise::Test::IntegrationHelpers

  setup do
    @dataset = datasets(:one)
    sign_in @dataset.user
  end

  test "visiting the index" do
    visit datasets_url
    assert_selector "h1", text: "Datasets"
  end

  test "should create dataset" do
    visit datasets_url
    click_on "New dataset"

    fill_in "Name", with: @dataset.name
    fill_in "Description", with: @dataset.description
    attach_file "File", Rails.root.join("test/fixtures/files/sample.csv")
    click_on "Create Dataset"

    assert_text "Dataset was successfully created"
    click_on "Back"
  end

  test "should update Dataset" do
    visit dataset_url(@dataset)
    click_on "Edit this dataset", match: :first

    fill_in "Name", with: @dataset.name
    fill_in "Description", with: @dataset.description
    click_on "Update Dataset"

    assert_text "Dataset was successfully updated"
    click_on "Back"
  end

  test "should destroy Dataset" do
    visit dataset_url(@dataset)
    click_on "Destroy this dataset", match: :first

    assert_text "Dataset was successfully destroyed"
  end


end
