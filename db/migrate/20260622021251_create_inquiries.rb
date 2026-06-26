class CreateInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :inquiries do |t|
      t.references :product, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :company_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :country
      t.integer :quantity
      t.string :color
      t.string :date_required
      t.text :comments

      t.timestamps
    end
  end
end
