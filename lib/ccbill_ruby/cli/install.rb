require 'thor/group'

module CCBill
  class CLI < Thor
    class Install < Thor::Group
      include Thor::Actions

      def self.source_root
        File.expand_path('../install', __FILE__)
      end

      def copy_config_file
        copy_file('ccbill.rb', 'config/initializers/ccbill.rb')
      end

      def copy_controller_file
        copy_file('ccbill_controller.rb', 'app/controllers/callbacks/ccbill_controller.rb')
      end

      def ignore_configuration
        inject_into_file 'config/routes.rb', before: /^end/ do
          <<-EOF

  namespace :callbacks do
    resource :ccbill, only: [:show, :create]
  end
          EOF
        end
      end
    end
  end
end
