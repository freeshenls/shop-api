class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :products, dependent: :nullify

  validates :name, presence: true

  before_validation :generate_slug, on: :create

  private

  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end
