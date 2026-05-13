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
      # TODO :add some functionality to check if the HTTP Header is valid
      if !identify_user(token)
        redirect_to root_url
      end
    end
  end

  def identify_user(token = "")
    # We've had issues with URL encoding, etc. causing issues so just to be safe
    # we will go ahead and unescape the user's token
    unescape_token(token)
    
    # Use secure auth_token validation instead of predictable SHA1 hash
    @user = User.find_by(auth_token: @clean_token)
    return !@user.nil?
  end

  # We had some issues with the token and url encoding...
  # this is an attempt to normalize the data.
  def unescape_token(token = "")
    @clean_token = CGI::unescape(token)
  end

  # Added a method to make it easy to figure out who the user is.
  def extrapolate_user
    # User is already identified in identify_user method via auth_token
    # No need to extract from token format since we're using secure tokens
    return @user
  end
end
