# frozen_string_literal: true
class TutorialsController < ApplicationController
  skip_before_action :has_info
  # Remove skip_before_action :authenticated to require authentication
  before_action :check_demo_mode, only: [:credentials]

  layout false, only: [:credentials]

  private

  def check_demo_mode
    # Only allow access in development/demo environments
    unless Rails.env.development? || Rails.env.test? || ENV['DEMO_MODE'] == 'true'
      redirect_to root_path, alert: 'Access denied. This feature is only available in demo mode.'
    end
  end
end
