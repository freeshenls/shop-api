class InquiriesController < ApplicationController
  def create
    permitted = inquiry_params

    @product = Product.find_by(id: permitted[:product_id])
    if @product.nil?
      render json: { success: false, errors: ["Product not found"] }, status: :unprocessable_entity
      return
    end

    # Format phone number with country prefix
    phone = permitted[:phone].to_s
    if phone.present?
      prefix = case permitted[:phone_country]
               when "Canada"         then "+1"
               when "United Kingdom" then "+44"
               when "Australia"      then "+61"
               else "+1"
               end
      phone = "#{prefix} #{phone}"
    end

    # Create and populate Inquiry model
    @inquiry = Inquiry.new(
      product:      @product,
      first_name:   permitted[:first_name],
      last_name:    permitted[:last_name],
      company_name: permitted[:company_name],
      email:        permitted[:email],
      phone:        phone,
      country:      permitted[:country],
      color:        permitted[:color],
      quantity:     permitted[:quantity],
      date_required: permitted[:date_required],
      comments:     permitted[:comments]
    )

    # Attach artwork upload if present
    @inquiry.artwork_file = permitted[:artwork] if permitted[:artwork].present?

    if @inquiry.save
      InquiryMailer.new_inquiry_notification(@inquiry, @product).deliver_now
      render json: { success: true, message: "Thank you! Your inquiry has been submitted successfully. Our team will contact you shortly." }
    else
      render json: { success: false, errors: @inquiry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.permit(
      :first_name, :last_name, :company_name, :email,
      :phone, :phone_country, :country, :color,
      :quantity, :date_required, :comments,
      :product_id, :artwork
    )
  end
end
