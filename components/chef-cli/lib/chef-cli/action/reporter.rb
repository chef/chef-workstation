require "chef/handler"
require "chef/resource/directory"

module ChefCLI
  class Reporter < ::Chef::Handler

    def report
      if exception
        Chef::Log.error("Creating exception report")
      else
        Chef::Log.info("Creating run report")
      end

      #ensure start time and end time are output in the json properly in the event activesupport happens to be on the system
      run_data = data
      run_data[:start_time] = run_data[:start_time].to_s
      run_data[:end_time] = run_data[:end_time].to_s

      Chef::FileCache.store("run-report.json", Chef::JSONCompat.to_json_pretty(run_data), 0640)
    end
  end
end
