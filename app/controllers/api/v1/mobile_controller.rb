# frozen_string_literal: true
class Api::V1::MobileController < ApplicationController
  before_action :mobile_request?
  before_action :validate_model_access

  respond_to :json

  # Allowlist of models that can be accessed via mobile API
  ALLOWED_MODELS = {
    'message' => Message,
    'schedule' => Schedule
  }.freeze

  def show
    if @model_class && params[:id]
      record = @model_class.accessible_by_user(current_user).find(params[:id])
      respond_with record.as_json
    else
      respond_with({ error: 'Invalid request' }.to_json, status: :bad_request)
    end
  rescue ActiveRecord::RecordNotFound
    respond_with({ error: 'Record not found' }.to_json, status: :not_found)
  end

  def index
    if @model_class
      # Implement pagination and user scoping instead of returning all records
      page = [params[:page]&.to_i || 1, 1].max # Ensure page is at least 1
      per_page = [params[:per_page]&.to_i || 10, 50].min # Max 50 records per page
      offset = (page - 1) * per_page
      
      scoped_records = @model_class.accessible_by_user(current_user)
      total_count = scoped_records.count
      total_pages = (total_count.to_f / per_page).ceil
      
      records = scoped_records.limit(per_page).offset(offset)
      
      respond_with({
        data: records.as_json,
        pagination: {
          current_page: page,
          per_page: per_page,
          total_pages: total_pages,
          total_count: total_count
        }
      }.to_json)
    else
      respond_with({ error: 'Invalid model' }.to_json, status: :bad_request)
    end
  end

  private

  def validate_model_access
    model_name = params[:class]&.downcase
    @model_class = ALLOWED_MODELS[model_name]
    
    unless @model_class
      respond_with({ error: 'Model not allowed or not found' }.to_json, status: :forbidden)
      return false
    end
  end

  def mobile_request?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /ios|android/i
    end
  end
end
