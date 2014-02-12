require 'httparty'
require 'multi_json'
require 'oj'

module LairClient

  class CLI
    include HTTParty

    def scan *sources

      options = sources.last.is_a?(Hash) ? sources.pop : {}

      config = YAML.load_file File.join(File.expand_path('~'), '.lair.yml')
      
      sources << Dir.pwd if sources.empty?
      check_sources *sources

      puts
      puts Paint["Scanning #{sources.length} directories...", :yellow]

      print Paint["Looking for nfo files...", :yellow]
      nfo_files = sources.inject([]){ |memo,source| memo + Dir.glob(File.join(source, '**', '*.nfo')) }

      if nfo_files.length == 0
        puts " found none"
        exit 0
      else
        puts Paint[" found #{nfo_files.length}", :green]
      end

      nfo_files = nfo_files[0, 3]

      nfo_files.each do |nfo_file|

        url = File.read(nfo_file).strip
        body = MultiJson.dump contents: { url: url }
        headers = { 'Content-Type' => 'application/json', 'Authorization' => %/Token token="#{config['api']['key']}"/ }
        res = self.class.post "#{config['api']['url']}/payloads/items", body: body, headers: headers

        puts res.code
        puts res.body if res.code != 200
      end

      puts
    end

    private

    def check_sources *sources
      sources.each do |source|
        if !File.exists? source
          raise SourceError, "No such directory #{source.inspect}"
        elsif !File.directory? source
          raise SourceError, "#{source.inspect} is not a directory"
        elsif !File.readable? source
          raise SourceError, "You do not have permission to read #{source.inspect}"
        end
      end
    end

    class SourceError < Error
      default_code 2
    end
  end
end
