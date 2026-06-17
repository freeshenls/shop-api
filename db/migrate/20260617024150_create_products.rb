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

      # 4. 系统自动时间戳
      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_index :products, :slug, unique: true
  end
end
