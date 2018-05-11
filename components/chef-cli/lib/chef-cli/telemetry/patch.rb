class ::Telemetry
  class Session
    # The telemetry session data is normally kept in .chef, which we don't have.
    def session_file
      ChefCLI::Config.telemetry_session_file.freeze
    end
  end

  def deliver(data = {})
    if ChefCLI::Config.telemetry.enable && !::Telemetry::Decision.env_opt_out?
      payload = event.prepare(data)
      client.await.fire(payload)
    end
  end
end
