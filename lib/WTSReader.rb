require "WTSReader/version"

module WTSReader
  class Reader
    def initialize(url, rate, voice, path, ext)
      @doc = Nokogiri::HTML(open(url))
      @rate = rate
      @voice = voice
      @path = path
      @ext = ext
    end
  end
end
