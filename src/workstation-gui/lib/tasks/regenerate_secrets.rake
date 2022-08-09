# This rake task will generate a new secret_key_base and an access_token.
# This task will overwrite the whole content of credentials.yml.enc and master.key files.

require 'securerandom'
require 'yaml'

KEY_PATH = 'config/master.key'.freeze
CONTENT_PATH = 'config/credentials.yml.enc'.freeze
CIPHER = 'aes-128-gcm'.freeze

namespace :secrets do
  desc "Regenerate the secret key base and the access token"
  task :regenerate, [:access_key] => [:environment] do |_task, args|
    # Generating the new secret_key_base and access_key
    secret_key = SecureRandom.hex(64)
    access_key = args[:access_key]
    access_key = SecureRandom.hex(16) if access_key.nil?

    # Generating the new master key and encryptor
    master_key_string = SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len(CIPHER))
    crypt = ActiveSupport::MessageEncryptor.new([ master_key_string ].pack("H*"), cipher: CIPHER)

    # Encrypting data
    encrypted_data = crypt.encrypt_and_sign(yaml_content(access_key, secret_key))

    # Write data to the files
    write_to_files(encrypted_data, master_key_string)
    puts "Regenerated the rails secrets"
  end
end

# TODO: Implement the regex replace in case the credential file needs to store more data
def yaml_content(access_key, secret)
  <<~YAML
    secret_key_base: #{secret}
    access_key: #{access_key}
  YAML
end

def write_to_files(data, key)
  IO.binwrite(Rails.application.root.join(CONTENT_PATH), data)
  File.write(Rails.application.root.join(KEY_PATH), key)
end
