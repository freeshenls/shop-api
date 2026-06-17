class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      # 1. 基础核心文本
      t.string :title
      t.string :sku
      t.string :slug
      t.references :category, foreign_key: true
      
      # 2. 核心价格与起订量
      t.string :price

      # 3. 大文本商品简述
      t.text :description

      # 4. 图片核心资产
      t.string :main_image_url
      
      # 5. SQLite 原生 JSON 矩阵
      t.json :image_urls

      # 6. 系统自动时间戳 (created_at 和 updated_at)
      t.timestamps
    end
    add_index :products, :sku, unique: true
    add_index :products, :slug, unique: true
  end
end
