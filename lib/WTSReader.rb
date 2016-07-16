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
    ## HTML PARSING
    def sanitize_document
      # Set's title before sanitizing in case title was removed in the filters
      set_title
      tag_noise = ['head', 'header', 'footer', 'script', 'style', 'img', 'video', 'audio']
      xpath_noise = ["//*[contains(.,'facebook')]", "//@*[contains(.,'twitter')]", "//@*[contains(.,'whatsapp')]", "//@*[contains(.,'pinterest')]"]
      xpath_noise.each {|x| @doc.search(x).remove()}
      tag_noise.each {|t| @doc.search(t).remove()}
    end
    def set_title
      @title = @doc.title
    end
    ## INTERFACE WITH SAY
    # determines if the kernel is `xnu` (OSX) or not (implied GNU Linux/BSD)
    # not used but possibly will be implemented for wider UNIX compatibility
    def set_speaker
      @reader = %x{ uname -v }.match(/root:xnu-\d+\.\d+/) ? "say" : "espeak"
    end
    # sets the voice manually. this will have to be built out with the cli
    def set_voice(voice)
      # Hash of {:language => [voice1, voice2, ...], language2 => [...], ...} goes here
      @voice = voice
    end
  end
end
