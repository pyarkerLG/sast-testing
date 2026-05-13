# frozen_string_literal: true
class DashboardController < ApplicationController
  skip_before_action :has_info
  layout false, only: [:change_graph]

  def home
    @user = current_user

    # See if the user has a font preference
    if params[:font]
      # Whitelist allowed font sizes to prevent XSS
      allowed_fonts = {
        'small' => '12px',
        'medium' => '16px', 
        'large' => '20px',
        'extra-large' => '24px'
      }
      
      if allowed_fonts.key?(params[:font])
        cookies[:font] = params[:font]
      end
    end
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
