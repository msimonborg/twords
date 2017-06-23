# frozen_string_literal: true

class Twords
  # include ConfigAccessable to access shared configuration settings
  module ConfigAccessible
    module_function

    def config
      Twords.config
    end
  end
end
