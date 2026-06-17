class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_one_attached :image
  has_many_attached :images

  validates :title, presence: true

  # 🎯 动态支持任意根分类作为作用域 (Scopes)
  def self.defined_scopes
    Category.level_1.map { |r| r.name.parameterize.underscore.to_sym } + (super rescue [])
  end

  def self.respond_to_missing?(method_name, include_private = false)
    Category.level_1.any? { |r| r.name.parameterize.underscore == method_name.to_s } || super
  end

  def self.method_missing(method_name, *args, &block)
    root = Category.level_1.find { |r| r.name.parameterize.underscore == method_name.to_s }
    if root
      where(category_id: category_ids_under_root(root.name))
    else
      super
    end
  end

  def self.category_ids_under_root(root_name)
    root = Category.find_by(name: root_name)
    return [] unless root

    # 获取该根分类下的所有子分类和孙分类 ID
    level_2_ids = Category.where(parent_id: root.id).select(:id)
    Category.where(id: root.id)
            .or(Category.where(parent_id: root.id))
            .or(Category.where(parent_id: level_2_ids))
            .select(:id)
  end
end
