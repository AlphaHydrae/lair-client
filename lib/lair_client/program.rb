# encoding: UTF-8
require 'commander'

class LairClient::Program < Commander::Runner

  GLOBAL_OPTIONS = [ :config, :verbose ]
  BACKTRACE_NOTICE = ' (use --trace to view backtrace)'

  include Commander::UI
  include Commander::UI::AskForClass

  def initialize argv = ARGV
    super argv

    program :name, 'lair'
    program :version, LairClient::VERSION
    program :description, 'Lair client.'

    global_option '-c', '--config PATH', 'Use a custom configuration file (defaults to ~/.lair.yml)'
    global_option '--verbose', 'Increase verbosity'

    command :scan do |c|
      c.syntax = 'lair scan'
      c.description = 'Scan files'
      c.action do |args,options|
        to_trace_or_not_to_trace options.trace do
          cli.scan *args, extract(options)
        end
      end
    end
  end

  private

  def cli
    LairClient::CLI.new
  end

  def to_trace_or_not_to_trace trace = false
    if trace
      yield
    else
      begin
        yield
      rescue ::LairClient::Error => e
        warn Paint["#{e.message}#{BACKTRACE_NOTICE}", :red]
        exit e.code
      end
    end
  end

  def extract *args
    options = args.pop
    (args | GLOBAL_OPTIONS).inject({}){ |memo,k| memo[k] = options.__send__(k); memo }.reject{ |k,v| v.nil? }
  end
end
