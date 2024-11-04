class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :datasets, dependent: :destroy
  has_many :models, through: :datasets
  has_many :deployments, through: :models

  validate :email_must_be_emich

  private

  def email_must_be_emich
    if email.present? && !email.end_with?('@emich.edu')
      errors.add(:email, 'must be an emich.edu email')
    end
  end
end
