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
      if !identify_user(token)
        redirect_to root_url
      end
    end
  end

  def identify_user(token = "")
    # Find user by secure auth_token
    @user = User.find_by(auth_token: token)
    return @user.present?
  end

  # Added a method to make it easy to figure out who the user is.
  def extrapolate_user
    # @user is already set in identify_user, no need to re-query
    # This method is kept for compatibility but no longer needed
  end
end
