module ChefCLI
  class StatusReporter

    def initialize(ui_element, prefix: nil, key: nil)
      @ui_element = ui_element
      @key = key
      @ui_element.update(prefix: prefix)
    end

    def update(msg)
      @ui_element.update({ @key => msg })
    end

    def success(msg)
      update(msg)
      @ui_element.success
    end

    def error(msg)
      update(msg)
      @ui_element.error
    end

  end
end
