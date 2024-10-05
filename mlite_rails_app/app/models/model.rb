class Model < ApplicationRecord
  has_one_attached :file

  validate :file_size
  def file_size
    if file.attached? && file.blob.byte_size > 500.megabytes
      errors.add(:file, "File size cannot be greater than 500MB")
    end
  end
end
