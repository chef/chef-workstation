require "r18n-desktop"

# A very thin wrapper around R18n, the idea being that we're likely to replace r18n
# down the road and don't want to have to change all of our commands.
module ChefWorkstation
  class Text
    R18n.from_env("i18n/")
    t = R18n.get.t
    t.translation_keys.each do |k|
      k = k.to_sym
      define_singleton_method k do |*args|
        TextWrapper.new(t.send(k, *args))
      end
    end
  end

  # Our text spinner class really doesn't like handling the TranslatedString or Untranslated classes returned
  # by the R18n library. So instead we return these TextWrapper instances which have dynamically defined methods
  # corresponding to the known structure of the R18n text file. Most importantly, if a user has accessed
  # a leaf node in the code we return a regular String instead of the R18n classes.
  class TextWrapper
    def initialize(translation_tree)
      @tree = translation_tree
      @tree.translation_keys.each do |k|
        k = k.to_sym
        define_singleton_method k do |*args|
          subtree = @tree.send(k, *args)
          if subtree.translation_keys.empty?
            # If there are no more possible children, just return the translated value
            subtree.to_s
          else
            TextWrapper.new(subtree)
          end
        end
      end
    end

    def method_missing(n, *args)
      raise "Tried to access i18n key #{@tree.instance_variable_get(:@path)}.#{n} but it does not exist"
    end
  end
end
