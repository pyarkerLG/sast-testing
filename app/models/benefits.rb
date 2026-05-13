# frozen_string_literal: true
class Benefits < ApplicationRecord

  def self.save(file, backup = false)
    data_path = Rails.root.join("public", "data")
    # Sanitize filename to prevent path traversal attacks
    safe_filename = File.basename(file.original_filename).gsub(/[^a-zA-Z0-9._-]/, '_')
    full_file_name = "#{data_path}/#{safe_filename}"
    f = File.open(full_file_name, "wb+")
    f.write file.read
    f.close
    make_backup(file, data_path, full_file_name) if backup == "true"
  end

  def self.make_backup(file, data_path, full_file_name)
    if File.exist?(full_file_name)
      # Sanitize filename to prevent command injection and path traversal
      safe_filename = File.basename(file.original_filename).gsub(/[^a-zA-Z0-9._-]/, '_')
      backup_path = "#{data_path}/bak#{Time.zone.now.to_i}_#{safe_filename}"
      
      begin
        FileUtils.cp(full_file_name, backup_path)
      rescue => e
        Rails.logger.error "Backup failed: #{e.message}"
      end
    end
  end

  def self.silence_streams(*streams)
    on_hold = streams.collect { |stream| stream.dup }
    streams.each do |stream|
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? "NUL:" : "/dev/null")
      stream.sync = true
    end
    yield
  ensure
    streams.each_with_index do |stream, i|
      stream.reopen(on_hold[i])
    end
  end
end
