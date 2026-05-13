# frozen_string_literal: true
class DashboardController < ApplicationController
  skip_before_action :has_info
  layout false, only: [:change_graph]

  def home
    @user = current_user

    # See if the user has a font preference
    if params[:font]
      cookies[:font] = sanitize_font_size(params[:font])
    end
  end

  private

  def sanitize_font_size(font_param)
    # Allow-list of safe font sizes mapped to CSS classes
    allowed_fonts = {
      'small' => 'font-small',
      'medium' => 'font-medium', 
      'large' => 'font-large',
      'extra-large' => 'font-extra-large'
    }
    
    # Return the CSS class if the font parameter is in our allow-list, otherwise default to medium
    allowed_fonts[font_param] || 'font-medium'
  end

  def change_graph
    self.try(params[:graph])

    if params[:graph] == "bar_graph"
      render "dashboard/bar_graph"
    else
      @user = current_user
      render "dashboard/pie_charts"
    end
  end
end
