require 'csv'

class Dataset < ApplicationRecord
  has_one_attached :file
  belongs_to :user
  has_many :models, dependent: :destroy
  # add validation for presence for name and dataet_tyop
  validates :name, presence: true
  validate :correct_file_type, :file_size_under_limit

  def parse_csv_to_hash
    dataset = Hash.new { |hash, key| hash[key] = [] }
    column_schema = columns # Assuming `columns` is a JSON column

    file.open do |csv_file|
      CSV.foreach(csv_file, headers: true) do |row|
        column_schema.each do |column|
          name = column["name"]
          dtype = column["dtype"]

          value = row[name]
          dataset[name] << cast_value(value, dtype)
        end
      end
    end

    dataset
  end

  private

  def cast_value(value, dtype)
    case dtype
    when "integer"
      value.to_i
    when "float"
      value.to_f
    when "boolean"
      %w[true 1].include?(value.to_s.downcase)
    when "categorical"
      value.to_s
    else
      value # Default to string if dtype is unrecognized
    end
  end

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