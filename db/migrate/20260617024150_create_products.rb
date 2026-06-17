class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      # 1. 基础核心文本
      t.string :title
      t.string :sku
      t.string :slug
      t.references :category, foreign_key: true
      
      # 2. 核心价格（🔥 终极退役 string，换成正规数字）
      # 用 decimal 存价格，精度锁定 10 位，保留 2 位小数。
      # 这样你以后在后台算总价、算折扣时，绝对不会出现浮点数丢精度的灵异事件。
      t.decimal :price, precision: 10, scale: 2

      # 3. 大文本商品简述
      t.text :description

      # 4. 图片核心资产
      t.string :main_image_url
      
      # 5. 🔥 PG 物理外挂：原生字符串数组 (String Array)
      # 既然用了 PG，咱们彻底抛弃恶心的 json 字符串序列化！
      # 直接用 PG 硬件支持的 array: true，底层就是真正的物理数组。
      t.string :image_urls, array: true, default: []

      # 6. 系统自动时间戳
      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_index :products, :slug, unique: true
  end
end
