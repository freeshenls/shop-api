class HomeController < ApplicationController
  def index
    # 1. 捞出全量 Banner (预加载 Active Storage 附件以消除 N+1 查询)
    @banners = Banner.with_attached_video
                     .with_attached_image_pc
                     .with_attached_image_mobile
                     .order(position: :asc)
    
    # 2. 💥 精准下发：只要一类分类！多余的二三级小品类绝不撑大前台瓷砖区
    @categories = Category.level_1
  end
end
