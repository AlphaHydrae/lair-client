require 'paint'

module LairClient
  VERSION = '0.1.0'

  class Error < StandardError
    attr_reader :code

    def self.default_code code = nil
      @default_code = code if code
      @default_code || 1
    end
    
    def initialize msg, code = nil
      super msg
      @code = code || self.class.default_code
    end
  end
end

Dir[File.join File.dirname(__FILE__), File.basename(__FILE__, '.*'), '*.rb'].each{ |lib| require lib }
