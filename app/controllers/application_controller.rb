# frozen_string_literal: true
class ApplicationController < ActionController::Base
  before_action :authenticated, :has_info, :create_analytic, :mailer_options
  helper_method :current_user, :is_admin?, :sanitize_font

  # Our security guy keep talking about sea-surfing, cool story bro.
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception

  private

  def mailer_options
    ActionMailer::Base.default_url_options[:protocol] = request.protocol
    ActionMailer::Base.default_url_options[:host]     = request.host_with_port
  end

  def current_user
    @current_user ||= find_user_by_auth_token || find_user_by_session
  end

  def find_user_by_auth_token
    return nil unless cookies[:auth_token].present?
    
    auth_token = cookies[:auth_token].to_s.strip
    
    # Validate auth_token format (should be Base64 encoded)
    return nil unless auth_token.match?(/\A[A-Za-z0-9+\/]*={0,2}\z/)
    
    begin
      # Attempt to decrypt and validate the auth_token
      decrypted_id = Encryption.decrypt_sensitive_value(auth_token)
      user_id = decrypted_id.to_i
      
      # Ensure the decrypted value is a valid positive integer
      return nil unless user_id > 0 && decrypted_id == user_id.to_s
      
      User.find_by(id: user_id, auth_token: auth_token)
    rescue => e
      # Log the error for security monitoring but don't expose details
      Rails.logger.warn "Invalid auth_token attempted: #{e.class}"
      nil
    end
  end

  def find_user_by_session
    return nil unless session[:user_id].present?
    
    user_id = session[:user_id].to_s.strip
    
    # Validate user_id is a positive integer
    return nil unless user_id.match?(/\A\d+\z/) && user_id.to_i > 0
    
    User.find_by(id: user_id.to_i)
  end

  def authenticated
     path = request.fullpath.present? ? root_url(url: request.fullpath) : root_url
     redirect_to path and reset_session if !current_user
  end

  def is_admin?
    current_user.admin if current_user
  end

  def administrative
    if !is_admin?
     redirect_to root_url
   end
  end

  def has_info
    redirect = false
    if current_user
      begin
      if !(current_user.retirement || current_user.paid_time_off || current_user.paid_time_off.schedule || current_user.work_info || current_user.performance)
        redirect = true
      end
      rescue
         redirect = true
      end
    end
    redirect_to home_dashboard_index_path if redirect
  end

  def create_analytic
    Analytics.create({ ip_address: request.remote_ip, referrer: request.referrer, user_agent: request.user_agent})
  end

  def sanitize_font(css)
    css
  end
end
