class Category < ApplicationRecord
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :children, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :products, dependent: :nullify

  validates :name, presence: true

  before_validation :generate_slug, on: :create

  def level
    if parent_id.nil?
      1
    elsif parent&.parent_id.nil?
      2
    else
      3
    end
  end

  # 用于后台 Scopes 筛选按钮 of Category
  scope :level_1, -> { where(parent_id: nil) }
  scope :level_2, -> { where.not(parent_id: nil).where(parent_id: Category.level_1.select(:id)) }
  scope :level_3, -> { where(parent_id: Category.where.not(parent_id: nil).where(parent_id: Category.level_1.select(:id)).select(:id)) }

  after_commit :sync_motor_product_scopes

  private

  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end

  def sync_motor_product_scopes
    # 查找 Motor::Resource 中的 product 资源配置
    product_resource = Motor::Resource.find_by(name: "product")
    return unless product_resource

    # 根据最新的 Category 一级分类动态生成 scopes 数组
    new_scopes = Category.level_1.map do |root|
      {
        "display_name" => root.name,
        "name" => root.name.parameterize.underscore
      }
    end

    # 更新 product_resource 的 preferences
    prefs = product_resource.preferences || {}
    prefs["scopes"] = new_scopes
    product_resource.update!(preferences: prefs)

    # 同步更新 Motor::Config 中的排序
    product_scope_order = Motor::Config.find_or_initialize_by(key: "resources.product.scopes.order")
    product_scope_order.value = new_scopes.map { |s| s["name"] }
    product_scope_order.save!

  end
end
