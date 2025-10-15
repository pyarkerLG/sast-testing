# frozen_string_literal: true
class PasswordResetsController < ApplicationController
  skip_before_action :authenticated

  def reset_password
    user = nil
    
    # Safely verify and extract user ID from signed token
    if params[:user_token].present?
      begin
        user_data = verifier.verify(params[:user_token])
        user = User.find_by(id: user_data[:user_id]) if user_data[:user_id]
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        # Token is invalid or tampered with
        user = nil
      end
    end

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
      # Generate a signed token containing only the user ID for the password reset form
      @user_token = verifier.generate({user_id: @user.id, expires_at: 1.hour.from_now})
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

  def verifier
    @verifier ||= ActiveSupport::MessageVerifier.new(Rails.application.secret_key_base)
  end

  def password_reset_mailer(user)
    token = generate_token(user.id, user.email)
    UserMailer.forgot_password(user.email, token).deliver
  end

  def generate_token(id, email)
    hash = Digest::MD5.hexdigest(email)
    "#{id}-#{hash}"
  end

  def is_valid?(token)
    if token =~ /(?<user>\d+)-(?<email_hash>[A-Z0-9]{32})/i

      # Fetch the user by their id, and hash their email address
      @user = User.find_by(id: $~[:user])
      email = Digest::MD5.hexdigest(@user.email)

      # Compare and validate our hashes
      return true if email == $~[:email_hash]
    end
  end
end
