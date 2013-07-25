# Copyright (c) 2013 MaestroDev.  All rights reserved.
require 'maestro_plugin'
require 'maestro_shell'

module MaestroDev
  module ShellPlugin
    class ConfigError < StandardError
    end
    
    class ShellWorker < Maestro::MaestroWorker
  
      def execute
        write_output("\nSHELL task starting\n", :buffer => true)
  
        begin
          validate_parameters
  
          Maestro.log.info "Inputs: command_string = #{@command_string}"
  
          shell = Maestro::Util::Shell.new
          command = create_command
          shell.create_script(command)
  
          write_output("\nRunning command:\n----------\n#{command.chomp}\n----------\n")
          exit_code = shell.run_script_with_delegate(self, :on_output)
  
          @error = shell.output unless exit_code.success?
        rescue ConfigError => e
          @error = e.message
        rescue Exception => e
          @error = "Error executing Shell Task: #{e.class} #{e}"
          Maestro.log.warn("Error executing Shell Task: #{e.class} #{e}: " + e.backtrace.join("\n"))
        end
    
        write_output "\n\nSHELL task complete\n"
        set_error(@error) if @error
      end
  
      def on_output(text)
        write_output(text, :buffer => true)
      end
  
      ###########
      # PRIVATE #
      ###########
      private
  
      def validate_parameters
        errors = []
  
        @command_string = get_field('command_string', '')
        @environment = get_field('environment', '')
        @env = @environment.empty? ? "" : "#{Maestro::Util::Shell::ENV_EXPORT_COMMAND} #{@environment.gsub(/(&&|[;&])\s*$/, '')} && "
  
        errors << "missing field command_string" if @command_string.empty?
  
        if !errors.empty?
          raise ConfigError, "Configuration errors: #{errors.join(', ')}"
        end
      end
  
      def create_command
        shell_command = "#{@env}#{@command_string}"
        set_field('command', shell_command)
        Maestro.log.debug("Running #{shell_command}")
        shell_command
      end
  
    end
  end
end
