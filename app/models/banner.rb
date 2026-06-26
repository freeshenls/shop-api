class Banner < ApplicationRecord
  # 👑 主媒体通道：桌面端大屏 JPG 或者是 MP4 视频
  has_one_attached :video

  # 高清海报图（JPG/PNG）
  has_one_attached :image_pc
  has_one_attached :image_mobile
end