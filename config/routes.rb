Rails.application.routes.draw do
  devise_for :users, only: :sessions
  authenticate :user do
    mount Motor::Admin => '/motor_admin'
  end

  # 👑 黄金拦截铁闸：如果发现来源页是从 motor_admin 退出来的，根路由直接截胡重新定向回去！
  constraints lambda { |req| req.referer&.include?('/motor_admin') || req.fullpath.include?('motor_admin') } do
    root to: redirect('/motor_admin'), as: :motor_admin_logout_forced_redirect
  end

  root "home#index"
  get "/products" => "products#index"
  get "/products/:slug" => "products#show", as: :product
  post "/inquiries" => "inquiries#create", as: :inquiries

  get "up" => "rails/health#show", as: :rails_health_check
end
