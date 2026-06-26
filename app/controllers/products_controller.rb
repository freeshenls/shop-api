class ProductsController < ApplicationController
  def index
    products_relation = Product.all

    # 1. Filter by search query (keyword matching title, category name, or sku) in database
    if params[:q].present?
      @query = params[:q].strip
      if @query.start_with?("#")
        sku_query = @query.delete_prefix("#").strip.downcase
        if sku_query.present?
          products_relation = products_relation.where(
            "LOWER(sku) = :exact OR LOWER(sku) LIKE :partial",
            exact: sku_query,
            partial: "%#{sku_query}%"
          )
        end
      else
        products_relation = products_relation.left_outer_joins(:category).where(
          "LOWER(products.title) LIKE :q OR LOWER(categories.name) LIKE :q OR LOWER(products.sku) LIKE :q",
          q: "%#{@query.downcase}%"
        )
      end
    end

    # 2. Filter by category tree in database
    if params[:category].present?
      @category_filter = params[:category].strip
      @active_category = Category.where("LOWER(name) = :q OR LOWER(slug) = :q", q: @category_filter.downcase).first
      if @active_category
        cat_ids = Product.category_ids_under_root(@active_category)
        products_relation = products_relation.where(category_id: cat_ids)
      end
    end

    # Extract categories tree structure for sidebar filter
    @categories_tree = Category.includes(children: :children).where(parent_id: nil).order(:id)

    # 5. Database-level Pagination with adjustable page sizes (15, 30, 60, 120)
    allowed_sizes = [15, 30, 60, 120]
    @per_page = params[:per_page].to_i
    @per_page = 15 unless allowed_sizes.include?(@per_page)

    @total_products = products_relation.count
    @total_pages = [1, (@total_products.to_f / @per_page).ceil].max
    
    @current_page = [1, params[:page].to_i].max
    @current_page = [@current_page, @total_pages].min
    
    start_index = (@current_page - 1) * @per_page
    
    # 优化③：预加载 Active Storage 附件及分类，消除 ProductCardComponent 渲染时的 N+1 查询
    @product_cards = products_relation
                       .includes(:category)
                       .with_attached_image
                       .with_attached_images
                       .limit(@per_page).offset(start_index).to_a
  end

  def show
    # 预加载完整分类链（最多 3 层），消除面包屑视图中的循环 find_by 查询
    @product = Product.includes(category: { parent: :parent })
                      .find_by("LOWER(slug) = ?", params[:slug].to_s.downcase)

    if @product
      @categories = Category.level_1.order(:name).pluck(:name)

      # 优化②：相关产品改为同分类优先，最多 1-2 次查询，替代原来的冗余双查
      same_cat_products = @product.category_id.present? ?
        Product.includes(:category).with_attached_image.with_attached_images
               .where(category_id: @product.category_id)
               .where.not(id: @product.id)
               .limit(3).to_a : []

      if same_cat_products.size < 3
        exclude_ids = [@product.id] + same_cat_products.map(&:id)
        same_cat_products += Product.includes(:category).with_attached_image.with_attached_images
                                    .where.not(id: exclude_ids)
                                    .limit(3 - same_cat_products.size).to_a
      end

      @related_products = same_cat_products
    else
      redirect_to products_path, alert: "Product not found."
    end
  end
end
