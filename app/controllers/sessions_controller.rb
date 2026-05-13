# frozen_string_literal: true
class SessionsController < ApplicationController
  skip_before_action :has_info
  skip_before_action :authenticated, only: [:new, :create]

  def new
    @url = params[:url]
    redirect_to home_dashboard_index_path if current_user
  end

  def create
    path = safe_redirect_path(params[:url])
    begin
      # Normalize the email address, why not
      user = User.authenticate(params[:email].to_s.downcase, params[:password])
    rescue RuntimeError => e
      # don't do ANYTHING
    end

    if user
      if params[:remember_me]
        cookies.permanent[:auth_token] = user.auth_token
      else
        session[:user_id] = user.id
      end
      redirect_to path
    else
      flash[:error] = e.message
      render "sessions/new"
    end
  end

  private

  def safe_redirect_path(url)
    return home_dashboard_index_path if url.blank?
    
    # Parse the URL to check if it's safe
    begin
      uri = URI.parse(url)
      
      # Only allow relative paths (no scheme, no host)
      if uri.scheme.nil? && uri.host.nil?
        # Ensure the path starts with / to prevent protocol-relative URLs
        url.start_with?('/') ? url : home_dashboard_index_path
      else
        home_dashboard_index_path
      end
    rescue URI::InvalidURIError
      home_dashboard_index_path
    end
  end

  def destroy
    cookies.delete(:auth_token)
    reset_session
    redirect_to root_path
  end
end
