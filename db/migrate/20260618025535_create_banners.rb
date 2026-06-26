class CreateBanners < ActiveRecord::Migration[8.1]
  def change
    create_table :banners do |t|
      # 🎯 排序：数字越小越靠前，前台人肉依此轮播
      t.integer :position, default: 0, null: false, comment: "画廊轮播物理排序位置"
      
      # 🎯 高奢品牌标语字段
      t.string :title, comment: "海报中央高奢大标题（如：SYPHOR）"
      t.string :subtitle, comment: "海报中央精细副标题（如：Innovative technology for modern home）"
      
      # 🎯 流量引流跳转胶囊
      t.string :redirect_link, comment: "胶囊按钮一键跳转引流链接（如：/categories/kitchen-appliances）"
      
      # 🎯 物理方位控制线：彻底干掉配置依赖，默认左侧，可选 top, bottom, left, right
      t.string :text_position, default: "left", null: false, comment: "文案显示方位：left, right, top, bottom"

      t.timestamps
    end
    
    # ⚡ 性能微操：为排序字段挂载索引，让前台在大吞吐流量时捞数快如闪电
    add_index :banners, :position
  end
end
