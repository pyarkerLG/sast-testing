# frozen_string_literal: true
class Api::V1::MobileController < ApplicationController
  before_action :mobile_request?
  before_action :validate_resource_access

  respond_to :json

  # Strict allowlist of permitted mobile API resources
  PERMITTED_RESOURCES = {
    'messages' => Message,
    'schedules' => Schedule
  }.freeze

  def show
    resource_class = get_permitted_resource_class
    return render json: { error: 'Resource not found' }, status: :not_found unless resource_class

    begin
      record = find_scoped_record(resource_class, params[:id])
      respond_with record.to_json
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Record not found' }, status: :not_found
    end
  end

  def index
    resource_class = get_permitted_resource_class
    return render json: { error: 'Resource not found' }, status: :not_found unless resource_class

    records = get_scoped_records(resource_class)
    respond_with records.to_json
  end

  private

  def mobile_request?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /ios|android/i
    end
  end

  def validate_resource_access
    # Ensure user is authenticated
    unless current_user
      render json: { error: 'Authentication required' }, status: :unauthorized
      return false
    end

    # Validate resource parameter
    unless params[:class].present? && PERMITTED_RESOURCES.key?(params[:class].downcase)
      render json: { error: 'Invalid or unauthorized resource' }, status: :forbidden
      return false
    end

    true
  end

  def get_permitted_resource_class
    resource_key = params[:class]&.downcase
    PERMITTED_RESOURCES[resource_key]
  end

  def find_scoped_record(resource_class, record_id)
    # Validate ID parameter
    unless record_id.present? && record_id.to_s.match?(/\A\d+\z/)
      raise ActiveRecord::RecordNotFound
    end

    # Scope records to current user when appropriate
    scoped_records = get_scoped_records(resource_class)
    scoped_records.find(record_id)
  end

  def get_scoped_records(resource_class)
    # Scope access based on user permissions and resource type
    case resource_class.name
    when 'Message'
      # Users can only access their own messages
      current_user.messages
    when 'Schedule'
      # Users can only access their own schedules through paid_time_off
      if current_user.paid_time_off
        current_user.paid_time_off.schedule
      else
        Schedule.none
      end
    else
      # Default: no access (should not reach here due to allowlist)
      resource_class.none
    end
  end
end
