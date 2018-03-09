require "r18n-desktop"

# A very thin wrapper around R18n, the idea being that we're likely to replace r18n
# down the road and don't want to have to change all of our commands.
module ChefWorkstation
  class Text

    R18n.from_env("i18n/")

    class << self
      def method_missing(n, *p)
        R18n.get.send(n, *p)
      end
    end

  end
end
