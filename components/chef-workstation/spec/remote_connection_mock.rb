module ChefWorkstation
  class RemoteConnectionMock
    def initialize(name, version, arch, is_linux)
      @os = {
        name: name,
        platform: { release: version, arch: arch },
      }
      # rubocop:disable Lint/NestedMethodDefinition
      if is_linux
        def @os.linux?; true; end
      else
        def @os.linux?; false; end
      end
      # rubocop:enable Lint/NestedMethodDefinition
    end

    def os; @os; end

    def run_command(command); end

    def upload_file(local, remote); end
  end
end
