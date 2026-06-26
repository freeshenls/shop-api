# app/models/motor/ability.rb
module Motor
  class Ability
    include CanCan::Ability

    def initialize(user)
      return unless user

      # 1. 所有人（包含运营员）都能对业务数据进行增删改查
      can :manage, [ActiveStorage::Attachment, Category, Product, Banner]

      if user.admin?
        # 2. 管理员拥有所有权限（可以修改 dashboards, queries, forms, alerts, configs 等）
        can :manage, :all
      end
    end
  end
end
