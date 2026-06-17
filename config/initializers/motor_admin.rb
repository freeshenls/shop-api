# config/initializers/motor_admin.rb
# frozen_string_literal: true

Rails.application.config.to_prepare do
  Motor::ApplicationController.class_eval do
    after_action do
      next unless response.content_type&.include?('text/html')

      css_rules = []

      # 1. 所有人均隐藏底部 Motor Admin 链接 (白标定制)
      css_rules << 'a[href*="github.com/motor-admin"] { display: none !important; }'

      # 2. 针对非管理员（运营员）隐藏全局搜索框
      if respond_to?(:current_user) && current_user && !current_user.admin?
        css_rules << <<~CSS
          .ivu-layout-header .ivu-input-wrapper,
          .ivu-layout-header .ivu-input-with-search,
          .ivu-layout-header input[placeholder*="Search"],
          .ivu-layout-header input[placeholder*="search"],
          .ivu-layout-header input[placeholder*="搜索"],
          button.header-btn:has(.ion-md-search),
          button.header-btn:has(i.ion-md-search) {
            display: none !important;
          }
        CSS
      end

      next if css_rules.empty?

      response.body = response.body.sub('</head>', <<~HTML.html_safe) rescue nil
        <style>
          #{css_rules.join("\n")}
        </style>
        </head>
      HTML
    end
  end
end
