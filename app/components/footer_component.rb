class FooterComponent < ViewComponent::Base
  def initialize(phone_number: "+86 17369698809", email_address: "info@gosyphor.com")
    @phone_number = phone_number
    @email_address = email_address
  end
end
