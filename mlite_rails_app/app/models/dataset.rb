class Dataset < ApplicationRecord
  has_one_attached :file
  belongs_to :user, optional: true
  has_many :models, dependent: :destroy
  # add validation for presence for name and dataet_tyop

  validate :correct_file_type, :file_size_under_limit

  private

  # Validate that the file is a .csv or .xlsx (Excel)
  def correct_file_type
    if file.attached? && !file.content_type.in?(%w[text/csv application/vnd.openxmlformats-officedocument.spreadsheetml.sheet])
      errors.add(:file, 'must be a CSV or Excel file')
    end
  end

  # Ensure the file is no larger than 500MB
  def file_size_under_limit
    if file.attached? && file.byte_size > 500.megabytes
      errors.add(:file, 'must be smaller than 500MB')
    end
  end
end