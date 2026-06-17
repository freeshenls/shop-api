# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 1. Clear existing data to start fresh
puts "Clearing existing data..."
Product.destroy_all
Category.destroy_all
User.destroy_all

# 2. Define the categories hierarchy tree based on the extracted HTML
categories_tree = {
  "Kitchen Appliances" => {
    "Food Preparation Appliances" => [
      "Blender", "Juice Extractor", "Grinder", "Slow Juicer", "Citrus Juicer",
      "Salad Maker", "Hand Mixer", "Milk Shake Maker", "Fufu Maker", "Stand Mixer",
      "Hand Blender", "Milk Frother", "Chopper", "Meat Grinder", "Soy Milk Maker",
      "Food Slicer", "Pasta Maker", "Ice Crusher", "Frozen Drink Maker", "Ice Cream Maker",
      "Vacuum Sealer", "Vegetable Cutter"
    ],
    "Baking Appliances" => [
      "Air Fryer", "Halogen Oven", "Deep Fryer", "Microwave Oven", "Sandwich Maker",
      "Waffle Maker", "Waffle Cone Maker", "Cake Maker", "Pop Maker", "Walnut Cookie Maker",
      "Grill Maker", "Raclette Table Grill", "Donut Maker", "Roti Maker", "Hamburger Maker",
      "Breakfast Maker", "Corn Dog Maker", "Crepe Maker", "Pizza Maker", "Bread Maker",
      "Toaster", "Cotton Candy Maker", "Popcorn Maker", "Oven", "Egg Boiler"
    ],
    "Cooking Appliances" => [
      "Pressure Cooker", "Rice Cooker", "Electric Stove", "Induction Cooker", "Radiant Cooker",
      "Gas Stove", "Electric Frying Pan", "Electric Cooker", "Yogurt Maker", "Food Dehydrator",
      "Electric Grill", "Chocolate Fountain Maker"
    ],
    "Drinking Water Appliances" => [
      "Electric Kettle", "Water Dispenser"
    ],
    "Coffee Serie" => [
      "Coffee Maker", "Turkish Coffee Maker", "Espresso Coffee Maker", "Coffee Roaster"
    ]
  },
  "Home Appliances" => {
    "Garment Care Appliances" => [
      "Shoes Dryer", "Steam Iron", "Hand Held Steamer", "Garment Steamer", "Lint Remover"
    ],
    "Cleaning Appliances" => [
      "Vacuum Cleaner", "Carpet Washer", "Window Cleaner Robot", "Steam Cleaner",
      "Clean Brush", "Mattress Vacuum Cleaner", "Vacuum Mop"
    ],
    "Home Comfort Appliances" => [
      "Fan", "Air Cooler", "Electric Heater", "Oil Filled Radiant Heater"
    ],
    "Scale" => [
      "Body Scale", "Price Computing Scale", "Kitchen Scale", "Coffee Scale",
      "Baby Scale", "Jewelry Scale", "Height Measuring Instrument"
    ],
    "Refrigeration Appliances" => [
      "Freezer", "Ice Maker"
    ],
    "Washing Appliances" => [
      "Washing Machine"
    ],
    "TVs" => []
  },
  "Beauty & Personal Care" => {
    "Hairstyling Appliances" => [
      "Hot Air Brush", "Straightening Comb", "Air Styler & Dryer", "Curling Iron"
    ]
  }
}

# 3. Recursive seeding helper
def seed_categories(tree, parent = nil)
  tree.each do |key, val|
    category = Category.find_or_create_by!(name: key, parent: parent)
    print "."
    if val.is_a?(Hash)
      seed_categories(val, category)
    elsif val.is_a?(Array)
      val.each do |sub_name|
        Category.find_or_create_by!(name: sub_name, parent: category)
        print "."
      end
    end
  end
end

puts "Seeding Category tree..."
seed_categories(categories_tree)
puts "\nCategory seeding finished! Total Categories: #{Category.count}"

# 4. Add some sample products for testing
puts "Seeding sample products..."
blender_cat = Category.find_by(name: "Blender")
air_fryer_cat = Category.find_by(name: "Air Fryer")
vacuum_cat = Category.find_by(name: "Vacuum Cleaner")

Product.find_or_create_by!(sku: "BLD-001") do |p|
  p.title = "High Speed Professional Blender"
  p.slug = "high-speed-professional-blender"
  p.category = blender_cat
  p.price = 89.99
  p.description = "A professional high speed blender for smoothies and shakes, featuring a 1200W motor."
end

Product.find_or_create_by!(sku: "AFR-002") do |p|
  p.title = "Digital Air Fryer 5.5L"
  p.slug = "digital-air-fryer-55l"
  p.category = air_fryer_cat
  p.price = 119.99
  p.description = "Healthy oil-free air fryer with digital touchscreen panel and 8 preset cooking modes."
end

Product.find_or_create_by!(sku: "VAC-003") do |p|
  p.title = "Cordless Smart Vacuum Cleaner"
  p.slug = "cordless-smart-vacuum-cleaner"
  p.category = vacuum_cat
  p.price = 249.99
  p.description = "Lightweight cordless stick vacuum with powerful suction, auto floor detection and 45-min runtime."
end

puts "Product seeding finished! Total Products: #{Product.count}"

# 5. Add some default users for testing Devise authentication & authorization
puts "Seeding Devise users..."
User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "admin"
end

User.find_or_create_by!(email: "operator@example.com") do |u|
  u.password = "password"
  u.password_confirmation = "password"
  u.role = "operator"
end
puts "Devise user seeding finished! Total Users: #{User.count}"
