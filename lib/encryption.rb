# frozen_string_literal: true
module Encryption

  # Added a re-usable encryption routine, shouldn't be an issue!
  def self.encrypt_sensitive_value(val = "")
     aes = OpenSSL::Cipher.new(cipher_type)
     aes.encrypt
     aes.key = key[0..31]
     
     # Generate a random IV for each encryption operation
     random_iv = aes.random_iv
     aes.iv = random_iv
     
     # Encrypt the value
     ciphertext = aes.update("#{val}") + aes.final
     
     # Prepend IV to ciphertext and encode
     iv_and_ciphertext = random_iv + ciphertext
     Base64.strict_encode64(iv_and_ciphertext).encode("utf-8")
  end

  def self.decrypt_sensitive_value(val = "")
     # Decode the base64 value first to extract IV and ciphertext
     decoded = Base64.strict_decode64("#{val}")
     
     # Extract IV (first 16 bytes) and ciphertext (remaining bytes)
     extracted_iv = decoded[0..15]
     ciphertext = decoded[16..-1]
     
     aes = OpenSSL::Cipher.new(cipher_type)
     aes.decrypt
     aes.key = key[0..31]
     aes.iv = extracted_iv
     aes.update(ciphertext) + aes.final
  end

  # Should be able to just re-use the same key we already have!
  def self.key
    # Use environment variable for production, fallback to constant for development
    env_key = ENV['ENCRYPTION_KEY']
    if env_key && !env_key.empty?
      env_key
    else
      raise "Key Missing. Set ENCRYPTION_KEY environment variable" if Rails.env.production?
      KEY if defined?(KEY)
    end
  end

  def self.cipher_type
    "aes-256-cbc"
  end

end
