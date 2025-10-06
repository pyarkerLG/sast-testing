# frozen_string_literal: true
class BenefitFormsController < ApplicationController

  def index
    @benefits = Benefits.new
  end

  def download
   begin
     # Validate and sanitize the filename to prevent directory traversal
     filename = params[:name]
     return redirect_to user_benefit_forms_path(user_id: current_user.id) if filename.blank?
     
     # Remove any path traversal attempts and ensure only filename
     safe_filename = File.basename(filename)
     return redirect_to user_benefit_forms_path(user_id: current_user.id) if safe_filename != filename
     
     # Validate file type parameter against whitelist
     allowed_types = ['pdf', 'doc', 'docx', 'txt']
     file_type = params[:type]
     return redirect_to user_benefit_forms_path(user_id: current_user.id) unless allowed_types.include?(file_type)
     
     # Construct safe file path within the data directory
     data_path = Rails.root.join("public", "data")
     file_path = data_path.join(safe_filename)
     
     # Ensure the file exists and is within the allowed directory
     return redirect_to user_benefit_forms_path(user_id: current_user.id) unless File.exist?(file_path)
     return redirect_to user_benefit_forms_path(user_id: current_user.id) unless file_path.to_s.start_with?(data_path.to_s)
     
     send_file file_path, disposition: "attachment"
   rescue => e
     Rails.logger.error "Download error: #{e.message}"
     redirect_to user_benefit_forms_path(user_id: current_user.id)
   end
  end

  def upload
    file = params[:benefits][:upload]
    if file
      flash[:success] = "File Successfully Uploaded!"
      Benefits.save(file, params[:benefits][:backup])
    else
      flash[:error] = "Something went wrong"
    end
    redirect_to user_benefit_forms_path(user_id: current_user.id)
  end

end
