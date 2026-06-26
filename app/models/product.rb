class Product < ApplicationRecord
  belongs_to :category, optional: true
  has_one_attached :image
  has_many_attached :images

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug

  private

  def generate_slug
    return if title.blank?
    base = title.parameterize
    candidate = base
    n = 1
    while Product.where(slug: candidate).where.not(id: id).exists?
      candidate = "#{base}-#{n}"
      n += 1
    end
    self.slug = candidate
  end

  public

  # 接收 Category 对象或根分类名字符串（兼容外部直接调用）
  def self.category_ids_under_root(root_or_name)
    root = root_or_name.is_a?(String) ? Category.find_by(name: root_or_name) : root_or_name
    return [] unless root

    # 获取该根分类下的所有子分类和孙分类 ID
    level_2_ids = Category.where(parent_id: root.id).select(:id)
    Category.where(id: root.id)
            .or(Category.where(parent_id: root.id))
            .or(Category.where(parent_id: level_2_ids))
            .select(:id)
  end

  # Motor Admin 每次构建 schema 时调用 defined_scopes，实时查 DB 保证准确。
  def self.defined_scopes
    category_scope_names = Category.level_1.map { |r| r.name.parameterize.underscore.to_sym }
    (category_scope_names + (super rescue [])).uniq
  end

  def self.respond_to_missing?(method_name, include_private = false)
    defined_scopes.include?(method_name.to_sym) || super
  end

  def self.method_missing(method_name, *args, &block)
    if defined_scopes.include?(method_name.to_sym)
      root = Category.find_by(parent_id: nil, slug: method_name.to_s.tr('_', '-'))
      root ? where(category_id: category_ids_under_root(root)) : none
    else
      super
    end
  end

end
