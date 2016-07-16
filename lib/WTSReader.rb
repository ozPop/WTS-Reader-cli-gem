require "WTSReader/version"
require "nokogiri"
require "open-uri"

module WTSReader
  class Reader
    # every instance of Reader can only have one document
    attr_reader :doc
    # `say` settings can be changed dynamically
    attr_accessor :rate, :voice, :path
    # default values are set for temporary files with default OSX voice at default rate (in word-per-minute)
    def initialize(url, rate=205, voice='Alex', path='/tmp/', ext='.aac')
      @doc = Nokogiri::HTML(open(url))
      @rate = rate
      @voice = voice
      @path = path
      @ext = ext
    end
    def text
      @doc.text
    end
  end
end
