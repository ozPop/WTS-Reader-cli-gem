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
      @filename = url.split('/')[-1].split('.')[0]
    end
    def text
      @doc.text
    end
    ## HTML PARSING
    def set_title
      @title = @doc.title
    end
    def sanitize_document
      # Set's title before sanitizing in case title was removed in the filters
      set_title
      tag_noise = ['head', 'header', 'footer', 'script', 'style', 'img', 'video', 'audio', 'figure', 'figcaption', 'param', '.related', "//*[contains(.,'topbar')]", "//*[contains(.,'related')]"]
      xpath_noise = ["//*[contains(.,'facebook')]", "//@*[contains(.,'twitter')]", "//@*[contains(.,'whatsapp')]", "//@*[contains(.,'pinterest')]"]
      xpath_noise.each {|x| @doc.search(x).remove()}
      tag_noise.each {|t| @doc.search(t).remove()}
    end
    def get_text
      @title + @doc.text.gsub('\n', ' ').gsub('"', '\"')
    end
    ## INTERFACE WITH SAY
    # determines if the kernel is `xnu` (OSX) or not (implied GNU Linux/BSD)
    # not used but possibly will be implemented for wider UNIX compatibility
    # def set_speaker
    #   @reader = %x{ uname -v }.match(/root:xnu-\d+\.\d+/) ? "say" : "espeak"
    # end
    # sets the voice manually. this will have to be built out with the cli
    def set_voice(voice)
      # Hash of {:language => [voice1, voice2, ...], language2 => [...], ...} goes here
      @voice = voice
    end
    def push_to_say
      sanitize_document
      text = get_text
      %x{ say -r #{@rate} -v #{@voice} -o #{@path + @filename + @ext} \"#{text}\" }
      %x{ open #{@path + @filename + @ext} }
    end
  end
end
