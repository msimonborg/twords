# frozen_string_literal: true

class Twords
  # include ConfigAccessable to access shared configuration settings
  module ConfigAccessible
    module_function

    # Provides a private method to access the shared config when included in a Module or Class
    #
    # @return [Twords::Configuration]
    def config
      Twords.config
    end
  end
end
