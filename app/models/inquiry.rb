class Inquiry < ApplicationRecord
  belongs_to :product, optional: true

  has_one_attached :artwork_file

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :company_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
