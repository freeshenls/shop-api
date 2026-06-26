class HeaderComponent < ViewComponent::Base
  # hero_page: true → 首页，header 透明起步，不渲染 spacer
  # hero_page: false (默认) → 其余页面，header 直接品牌蓝，渲染 spacer
  def initialize(query: nil, hero_page: false)
    @query           = query
    @hero_page       = hero_page
    @mobile_cat_tree = Category.includes(children: :children).where(parent_id: nil).order(:id)
    @mobile_cat_tree = [] if @mobile_cat_tree.empty?
    # 保留旧变量供桌面 mega menu 兼容
    @header_categories = @mobile_cat_tree.map(&:name)
    @header_categories = ["Kitchen Appliances", "Home Appliances", "Beauty & Personal Care"] if @header_categories.empty?
  end

  def active_class?(path)
    request.path == path ? "active" : ""
  rescue
    ""
  end
end
