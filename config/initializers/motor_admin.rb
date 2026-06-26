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

      # 3. 将左上角 Home 按钮的 Bolt 图标替换为 Syphor 品牌 Logo（白色版）
      logo_path = ActionController::Base.helpers.asset_path('logo_syphor_white.png')
      css_rules << <<~CSS
        a.ivu-btn[href="/motor_admin/"] svg {
          display: none !important;
        }
        a.ivu-btn[href="/motor_admin/"] span div.d-flex {
          width: 90px !important;
          height: 24px !important;
          background-image: url('#{logo_path}') !important;
          background-size: contain !important;
          background-repeat: no-repeat !important;
          background-position: center !important;
        }
        a.ivu-btn[href="/motor_admin/"] {
          width: auto !important;
          height: 40px !important;
          padding: 0 10px !important;
          background-color: transparent !important;
          border-color: transparent !important;
          box-shadow: none !important;
          display: inline-flex !important;
          align-items: center !important;
          justify-content: center !important;
        }
      CSS
      overrides_path = ActionController::Base.helpers.asset_path('overrides.css')
      style_tag = css_rules.any? ? "<style>\n#{css_rules.join("\n")}\n</style>" : ""

      response.body = response.body.sub('</head>', <<~HTML.html_safe) rescue nil
        <link rel="stylesheet" href="#{overrides_path}">
        #{style_tag}
        </head>
      HTML
    end
  end
end
