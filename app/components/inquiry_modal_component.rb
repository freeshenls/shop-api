class InquiryModalComponent < ViewComponent::Base
  include ApplicationHelper

  def initialize(product:)
    @product = product
  end
end
