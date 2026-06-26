class ChangePriceDefaultOnProducts < ActiveRecord::Migration[8.1]
  def change
    change_column_default :products, :price, from: nil, to: 0.00
  end
end
