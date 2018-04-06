require "net/http"
require "uri"
require "chef-workstation/config"
require "chef-workstation/log"

module ChefWorkstation
  class FileFetcher
    def self.fetch(path)
      cache_path = ChefWorkstation::Config.cache.path
      FileUtils.mkdir_p(cache_path)
      url = URI.parse(path)
      name = File.basename(url.path)
      local_path = File.join(cache_path, name)

      # TODO header check for size or checksum?
      return local_path if File.exist?(local_path)

      temp_path = "#{local_path}.downloading"
      file = open(temp_path, "wb")
      ChefWorkstation::Log.debug "Downloading: #{temp_path}"
      Net::HTTP.start(url.host) do |http|
        begin
          http.request_get(url.path) do |resp|
            resp.read_body do |segment|
              file.write(segment)
            end
          end
        rescue e
          @error = true
          raise
        ensure
          file.close()
          # If any failures occurred, don't risk keeping
          # an incomplete download that we'll see as 'cached'
          if @error
            FileUtils.rm_f(temp_path)
          else
            FileUtils.mv(temp_path, local_path)
          end
        end
      end
    end
  end
end

