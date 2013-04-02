require 'optparse'

module Reloadlive
  help = <<HELP
Reloadlive is command line tool to easily preview your github-markup files

Basic Command Line Usage:
  reloadlive [OPTIONS] [DIRS]
HELP
  @@options = { 'port' => 4567, 'host' => '0.0.0.0', 'static' => Dir.pwd }
  options_parser = OptionParser.new do |opts|
    opts.banner = help

    opts.on("--port [PORT]", "Bind port (default 4567).") do |port|
      @@options['port'] = port.to_i
    end

    opts.on("--host [HOST]", "Hostname or IP address to listen on (default 0.0.0.0).") do |host|
      @@options['bind'] = host
    end

    opts.on("--static [PATH]", "Specify the static path.") do |path|
      @@options['static'] = path
    end

    opts.on("--version", "Display current version.") do
      puts "Reloadlive " + Reloadlive::VERSION
      exit 0
    end
  end

  begin
    options_parser.parse!
  rescue OptionParser::InvalidOption
    puts "reloadlive: #{$!.message}"
    puts "reloadlive: try 'reloadlive --help' for more information"
    exit
  end


  if ARGV.empty?
    @@options['watch'] = [Dir.pwd]
  else
    @@options['watch'] = ARGV.dup
  end

  def options
    @@options
  end

  def self.options
    @@options
  end
end
