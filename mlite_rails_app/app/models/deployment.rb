class Deployment < ApplicationRecord
  belongs_to :model

  validates :name, presence: true
  validates :status, presence: true
  # validates :deployment_link, presence: true
end
