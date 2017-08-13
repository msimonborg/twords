# frozen_string_literal: true

require 'rails/generators'

class Twords
  module Generators
    # Generate a configuration template for partials.
    class TwordsGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def copy_config_file
        template 'twords.rb.erb', 'config/initializers/twords.rb'
      end
    end
  end
end