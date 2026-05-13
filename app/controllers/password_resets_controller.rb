# frozen_string_literal: true
class PasswordResetsController < ApplicationController
  skip_before_action :authenticated

  def reset_password
    user = Marshal.load(Base64.decode64(params[:user])) unless params[:user].nil?

    if user && params[:password] && params[:confirm_password] && params[:password] == params[:confirm_password]
      user.password = params[:password]
      user.save!
      flash[:success] = "Your password has been reset please login"
      redirect_to :login
    else
      flash[:error] = "Error resetting your password. Please try again."
      redirect_to :login
    end
  end

  def confirm_token
    if !params[:token].nil? && is_valid?(params[:token])
      flash[:success] = "Password reset token confirmed! Please create a new password."
      render "password_resets/reset_password"
    else
      flash[:error] = "Invalid password reset token. Please try again."
      redirect_to :login
    end
  end

  def send_forgot_password
    @user = User.find_by_email(params[:email]) unless params[:email].nil?

    if @user && password_reset_mailer(@user)
      flash[:success] = "Password reset email sent to #{params[:email]}"
      redirect_to :login
    else
      flash[:error] = "There was an issue sending password reset email to #{params[:email]}".html_safe unless params[:email].nil?
    end
  end

  private

  def password_reset_mailer(user)
    token = generate_token(user.id, user.email)
    UserMailer.forgot_password(user.email, token).deliver
  end

  def generate_token(id, email)
    # Generate cryptographically secure random token
    random_token = SecureRandom.urlsafe_base64(32)
    
    # Create expiration timestamp (1 hour from now)
    expires_at = (Time.current + 1.hour).to_i
    
    # Create payload with user id, email, expiration, and random component
    payload = "#{id}:#{email}:#{expires_at}:#{random_token}"
    
    # Generate HMAC signature using application secret
    secret_key = Rails.application.secret_key_base || 'fallback_secret_key'
    signature = OpenSSL::HMAC.hexdigest('SHA256', secret_key, payload)
    
    # Encode the complete token
    Base64.urlsafe_encode64("#{payload}:#{signature}")
  end

  def is_valid?(token)
    return false if token.blank?
    
    begin
      # Decode the token
      decoded = Base64.urlsafe_decode64(token)
      parts = decoded.split(':')
      
      return false if parts.length != 5
      
      user_id, email, expires_at, random_token, signature = parts
      
      # Verify expiration
      return false if Time.current.to_i > expires_at.to_i
      
      # Fetch the user by their id
      @user = User.find_by(id: user_id)
      return false unless @user
      
      # Verify email matches
      return false unless @user.email == email
      
      # Verify HMAC signature
      payload = "#{user_id}:#{email}:#{expires_at}:#{random_token}"
      secret_key = Rails.application.secret_key_base || 'fallback_secret_key'
      expected_signature = OpenSSL::HMAC.hexdigest('SHA256', secret_key, payload)
      
      # Use secure comparison to prevent timing attacks
      return false unless ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
      
      # Check if token has been used (implement one-time use)
      # Store used tokens in Rails cache with expiration
      cache_key = "used_password_reset_token:#{Digest::SHA256.hexdigest(token)}"
      return false if Rails.cache.exist?(cache_key)
      
      # Mark token as used (expires in 2 hours to handle clock skew)
      Rails.cache.write(cache_key, true, expires_in: 2.hours)
      
      return true
      
    rescue => e
      Rails.logger.warn "Password reset token validation error: #{e.message}"
      return false
    end
  end
end
