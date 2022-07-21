unless defined?(Rails)

  puts "This script works within Rails project environment and should be run with rails runner"

else

  require 'securerandom'
  require 'yaml'

  # activesupport/lib/active_support/encrypted_file.rb

  content_path = "config/credentials.yml.enc"
  key_path = "config/master.key"

  # decrypt and read credentials.yml.enc with master.key

  @credentials ||= Rails.application.encrypted(content_path, key_path: key_path)

  # replace secret_key_base and encrypt credentials.yml
  mcookie = SecureRandom.hex(64)

  begin
    content = @credentials.read.gsub(/secret_key_base:.*/, "secret_key_base: #{mcookie}")
  rescue ActiveSupport::MessageEncryptor::InvalidMessage
    puts "Couldn't decrypt config/credentials.yml.enc, either the file is corrupted or was not encrypted with the key in config/master.key"
    puts "Please run `rails credentials:edit` in the Rails app root"
  end

  CIPHER = "aes-128-gcm"

  secret_key_string = SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len(CIPHER))

  crypt = ActiveSupport::MessageEncryptor.new([ secret_key_string ].pack("H*"), cipher: CIPHER)

  encrypted_data = crypt.encrypt_and_sign(content)

  # encrypted_file.rb write()
  IO.binwrite(Rails.application.root.join(content_path), encrypted_data)
  File.write(Rails.application.root.join(key_path), secret_key_string)
end

