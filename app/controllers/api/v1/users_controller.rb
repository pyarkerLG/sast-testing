# frozen_string_literal: true
class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticated
  before_action :valid_api_token
  before_action :extrapolate_user

  respond_to :json

  def index
    respond_with @user.admin ? User.all : @user
  end

  def show
    respond_with @user.as_json
  end

  private

  def valid_api_token
    authenticate_or_request_with_http_token do |token, options|
      @user = authenticate_with_token(token)
      unless @user
        render json: { error: 'Invalid or expired token' }, status: :unauthorized
        return false
      end
      true
    end
  end

  def authenticate_with_token(token)
    return nil if token.blank?
    
    # Find user by API token
    user = User.find_by(auth_token: token)
    return nil unless user
    
    # Check if token is expired
    if user.token_expired?
      return nil
    end
    
    user
  end

  # Added a method to make it easy to figure out who the user is.
  def extrapolate_user
    # @user is already set in valid_api_token, no need to re-fetch
    @user ||= nil
  end
end
