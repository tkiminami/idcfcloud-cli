require 'logger'
require 'thor'
require 'active_support'
require 'active_support/core_ext'
require_relative './version'
require 'idcf/cli/conf/const'
require 'idcf/cli/error/cli_error'
require_relative './validate/custom/init'
require_relative './gem_ext/thor/init_util'
require_relative './extend/init'
require 'idcf/cli/error/init'
require 'idcf/cli/lib/util/cli_file'
require 'idcf/cli/lib/util/cli_logger'

module Idcf
  module Cli
    # Index
    class Index < Thor
      @variables = nil
      # command alias [alias] => [command]
      COMMAND_MAPS = {}.freeze

      include Idcf::Cli::Extend::Init

      class << self
        # init
        #
        # @param arg [Hash] options
        def init(arg)
          map COMMAND_MAPS
          add_classify_rule
          sub_command_regist('controller', File.dirname(__FILE__), arg)
        rescue Idcf::Cli::Error::CliError => e
          error_exit(e)
        rescue StandardError => e
          error_exit(Idcf::Cli::Error::CliError.new(e.message))
        end

        protected

        # add classify rule
        def add_classify_rule
          Idcf::Cli::Conf::Const::CLASSIFY_RULE.each do |rule|
            ActiveSupport::Inflector.inflections do |inflect|
              inflect.irregular(*rule)
            end
          end
        end
      end

      def initialize(*args)
        @variables = {}
        super(*args)
      end

      desc 'init', 'initialize'
      options global:  true,
              profile: 'default'

      def init
        configure
        update
      rescue StandardError => e
        self.class.error_exit(e)
      end

      desc 'update', 'list update'

      def update
        do_update(options)
      rescue StandardError => e
        self.class.error_exit(e)
      end

      desc 'configure', 'create configure'
      options global:  true,
              profile: 'default'

      def configure
        init_f = ARGV[0] == 'init'
        do_configure(options, init_f)
      rescue StandardError => e
        self.class.error_exit(e)
      end

      desc 'version', 'version string'

      def version
        puts Idcf::Cli::Conf::Const::VERSION_STR
      rescue StandardError => e
        self.class.error_exit(e)
      end
    end
  end
end
