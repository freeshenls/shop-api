class AddSpecificationsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :specifications, :text
  end
end
