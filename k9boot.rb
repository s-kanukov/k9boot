require 'optparse'
require_relative 'k9boot/rails_app_builder'

def main
  options = parse_options
  K9Boot::RailsAppBuilder.new(get_app_name(options), options.key?(:admin))
                         .build
end

def parse_options
  options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: example.rb [options]'

    opts.on('-nNAME', '--name=NAME', 'Application name') do |name|
      options[:name] = name
    end

    opts.on('-a', '--create-admin', 'Generate advanced template with ' \
            'frontend and admin sections') do |admin|
      options[:admin] = admin
    end

    opts.on('-h', '--help', 'Prints this help') do
      puts opts
      exit
    end
  end.parse!
  options
end

def get_app_name(options)
  return options[:name] if options.key?(:name)

  print 'Enter application name (default is ' \
        "#{K9Boot::RailsAppBuilder::DEFAULT_APP_NAME}): "
  name = gets.chomp.strip
  name
end

main if __FILE__ == $PROGRAM_NAME
