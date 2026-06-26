module ApplicationHelper
  # ==========================================
  # Brand Color Tokens
  # ==========================================

  # SYPHOR logo blue — RGB(36, 59, 81) — used as primary brand background (header/nav)
  LOGO_BLUE       = "#243B51".freeze
  LOGO_BLUE_DARK  = "#182A3A".freeze  # ~20% darkened for hover states
  LOGO_BLUE_LIGHT = "#2E4D68".freeze  # ~20% lightened for accents

  # Button blue — brighter mid-blue for CTA buttons (higher contrast on light backgrounds)
  BTN_BLUE       = "#1F4E72".freeze
  BTN_BLUE_DARK  = "#163A55".freeze  # hover state

  # SYPHOR logo red — RGB(180, 79, 67) — used as accent / highlight color
  LOGO_RED        = "#B44F43".freeze
  LOGO_RED_DARK   = "#8F3B31".freeze  # ~20% darkened for hover states
  LOGO_RED_LIGHT  = "#C96B5F".freeze  # ~20% lightened for accents

  # Returns the logo blue hex color string
  def logo_blue       = LOGO_BLUE
  def logo_blue_dark  = LOGO_BLUE_DARK
  def logo_blue_light = LOGO_BLUE_LIGHT

  # Returns the logo red hex color string
  def logo_red        = LOGO_RED
  def logo_red_dark   = LOGO_RED_DARK
  def logo_red_light  = LOGO_RED_LIGHT

  # Returns the button blue hex color string
  def btn_blue        = BTN_BLUE
  def btn_blue_dark   = BTN_BLUE_DARK

  # Deep active/accent blue (often used for focus, links, pagination, and quote CTAs)
  ACTIVE_BLUE       = "#074277".freeze
  ACTIVE_BLUE_DARK  = "#052e54".freeze

  def active_blue       = ACTIVE_BLUE
  def active_blue_dark  = ACTIVE_BLUE_DARK

  # ==========================================
  # Design Tokens & Layout Methods
  # ==========================================

  # Standard layout page wrapper container
  def container_custom
    "max-w-[1300px] mx-auto px-6"
  end

  # Standard content panels and card wrappers
  def panel_card
    "bg-white border border-[#e2e8f0] rounded-[6px] p-6 shadow-sm"
  end

  # Check if a category is part of the active path for sidebar tree expansion
  def active_path?(category, active_category)
    return false unless active_category
    return true if category.id == active_category.id
    return true if active_category.parent_id == category.id
    return true if active_category.parent&.parent_id == category.id
    false
  end

  # ==========================================
  # Button Styles
  # ==========================================

  # Primary branding CTA button
  def btn_primary
    "inline-flex items-center justify-center bg-[#{BTN_BLUE}] hover:bg-[#{BTN_BLUE_DARK}] text-[#f8fafc] py-3 px-7 rounded-[6px] font-['Outfit'] font-bold shadow-lg transition-all duration-300 hover:-translate-y-0.5 hover:shadow-[0_6px_20px_rgba(31,78,114,0.4)]".html_safe
  end

  # Secondary outline/border action button
  def btn_secondary
    "inline-flex items-center justify-center border border-[#e2e8f0] bg-white text-[#64748b] py-3 px-7 rounded-[6px] font-['Outfit'] font-bold transition-all duration-300 hover:text-[#0f172a] hover:border-[#0f172a]".html_safe
  end

  # ==========================================
  # Header / Nav Style Tokens
  # ==========================================

  # Desktop header navigation link — white text, uppercase, bold
  # Usage: <a href="…" class="<%= nav_link %>">Home</a>
  def nav_link
    "text-sm font-bold tracking-widest text-white hover:text-white/70 transition-colors duration-200 uppercase no-underline"
  end

  # Mega menu dropdown — category item link
  # Usage: <a href="…" class="<%= mega_menu_link %>">Air Fryer</a>
  def mega_menu_link
    "text-xs text-neutral-500 hover:text-[#{LOGO_BLUE}] font-medium transition-colors no-underline"
  end

  # Mega menu dropdown — column section heading
  # Usage: <h3 class="<%= mega_menu_heading %>">Small Kitchen Appliances</h3>
  def mega_menu_heading
    "font-bold text-sm text-neutral-900 tracking-wider uppercase mb-3 border-b border-neutral-100 pb-2"
  end

  # Mobile drawer navigation link — full-width, white, bold uppercase
  # Usage: <a href="…" class="<%= mobile_nav_link %>">Home</a>
  # Pass extra: mobile_nav_link("border-b border-white/10") for divider rows
  def mobile_nav_link(extra = "")
    base = "block py-3 text-sm font-black text-white hover:text-white/70 uppercase tracking-widest no-underline"
    extra.present? ? "#{base} #{extra}" : base
  end

  # ==========================================
  # Typography & Decoration Tokens
  # ==========================================

  # Main page title / Product title
  def heading_title
    "font-['Outfit'] font-extrabold text-[#0f172a]".html_safe
  end

  # Sub-headings / section headings
  def heading_sub
    "font-['Outfit'] font-bold text-[#0f172a]".html_safe
  end

  # Accent divider bar
  def divider_bar
    "w-12 h-1 bg-[#2b70ad] rounded-full".html_safe
  end

  # Standard focus state class for inputs
  def input_focus
    "focus:border-[#{ACTIVE_BLUE}] focus:shadow-[0_0_0_3px_rgba(7,66,119,0.08)]".html_safe
  end

  # Accent action button (e.g. Request a Quote, Submit Inquiry)
  def btn_action_accent
    "bg-[#{ACTIVE_BLUE}] hover:bg-[#{ACTIVE_BLUE_DARK}] text-white font-['Outfit'] font-bold transition-all duration-200 cursor-pointer border-none flex items-center justify-center".html_safe
  end

  # Home / Brand section headings
  def heading_home_section
    "font-['Outfit'] font-black tracking-tight uppercase text-neutral-900".html_safe
  end

  # Standard styling for form labels
  def form_label
    "font-['Inter'] text-[13px] font-bold text-[#0f172a]".html_safe
  end

  # Base styling for form fields
  def form_field_base
    "w-full border border-[#e2e8f0] rounded-[6px] px-2.5 font-['Inter'] text-[13.5px] text-[#0f172a] outline-none bg-white transition-all duration-300 box-border".html_safe
  end

  # Helper to build category links that preserve other active active filters
  def category_filter_url(cat = nil)
    url_parts = []
    url_parts << "category=#{CGI.escape(cat.to_s)}" if cat.present?
    if respond_to?(:params) && params.present?
      url_parts << "q=#{CGI.escape(params[:q].to_s)}" if params[:q].present?
      url_parts << "per_page=#{params[:per_page]}" if params[:per_page].present?
    end
    "/products" + (url_parts.any? ? "?" + url_parts.join("&") : "")
  end

  # Helper to build page size links that preserve category and query filters
  def page_size_url(size)
    url = "/products?per_page=#{size}"
    if respond_to?(:params) && params.present?
      url += "&category=#{CGI.escape(params[:category].to_s)}" if params[:category].present?
      url += "&q=#{CGI.escape(params[:q].to_s)}" if params[:q].present?
    end
    url
  end

  # Detect if the current request is from a mobile browser
  def mobile_device?
    return false unless respond_to?(:request) && request.present?
    user_agent = request.user_agent.to_s.downcase
    user_agent.match?(/mobile|android|iphone|ipad|iemobile|opera mini/i)
  end
end
