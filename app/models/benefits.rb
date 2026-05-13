# frozen_string_literal: true
require 'fileutils'

class Benefits < ApplicationRecord

  def self.save(file, backup = false)
    data_path = Rails.root.join("public", "data")
    # Sanitize filename using File.basename to prevent directory traversal
    sanitized_filename = sanitize_filename(file.original_filename)
    full_file_name = "#{data_path}/#{sanitized_filename}"
    f = File.open(full_file_name, "wb+")
    f.write file.read
    f.close
    make_backup(sanitized_filename, data_path, full_file_name) if backup == "true"
  end

  def self.make_backup(sanitized_filename, data_path, full_file_name)
    if File.exist?(full_file_name)
      backup_filename = "#{data_path}/bak#{Time.zone.now.to_i}_#{sanitized_filename}"
      # Use FileUtils.cp instead of system() to prevent command injection
      FileUtils.cp(full_file_name, backup_filename)
    end
  end

  private

  def self.sanitize_filename(filename)
    # Use File.basename to strip directory components and prevent path traversal
    basename = File.basename(filename.to_s)
    # Remove or replace dangerous characters, keep only alphanumeric, dots, hyphens, underscores
    sanitized = basename.gsub(/[^a-zA-Z0-9.\-_]/, '_')
    # Ensure filename is not empty and doesn't start with dot (hidden files)
    sanitized = 'upload' if sanitized.empty? || sanitized.start_with?('.')
    # Limit filename length to prevent issues
    sanitized = sanitized[0, 255] if sanitized.length > 255
    sanitized
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
