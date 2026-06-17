class Product < ApplicationRecord
  belongs_to :category, optional: true

  validates :title, presence: true
end
