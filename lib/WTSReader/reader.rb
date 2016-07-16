class WTSReader::Reader
  # every instance of Reader can only have one document
  attr_reader :doc
  # `say` settings can be changed dynamically
  attr_accessor :rate, :voice, :path
  # default values are set for temporary files with default OSX voice at default rate (in word-per-minute)
  def initialize(url, rate=205, voice='Alex', path='/tmp/', ext='.aac')
    @url = url

    @doc = Nokogiri::HTML(open(url))
    @rate = rate
    @voice = voice
    @path = path
    @ext = ext
    @filename = Random.new.to_s.split(':')[1][0..-2]
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
    tag_noise = ['head', 'header', 'footer', 'script', 'style', 'img', 'video', 'audio', 'figure', 'figcaption', 'param', '.related','.header','.nav','nav', '#header', '#footer','.footer', 'user-details','.sidebar','#sidebar', '.favicon','#favicon','#hot-network-questions']
    # xpath_noise = ["//*[contains(.,'facebook')]", "//@*[contains(.,'twitter')]", "//@*[contains(.,'whatsapp')]", "//@*[contains(.,'pinterest')]"]
    tag_noise.each {|t| @doc.search(t).remove()}
  end
  def get_text
    @text = @title + @doc.text.gsub('\n', ' ').gsub('"', '\"')
    if @text
true
    end
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
  def set_speed(rate)
    # allows used to set words-per-minute manually
    return rate if rate.is_a?(integer)
    # otherwise gives user-friendly options
    speeds = {:slowest => 130, :slow => 170, :average => 205, :fast => 225, :fastest => 270}
    if speeds.include?(rate.to_sym)
speeds[rate.to_sym]
    else
"Speed setting `#{rate}` not understood"
    end
  end
  def get_file_location
    @path + @filename + @ext
  end
  def push_to_say
    match = WTSReader::Profile.any_matches?(@url)
    if match
      puts match
      text = WTSReader::Profile.send(match, @doc)
      binding.pry
    else
      sanitize_document
      get_text
      text = @text
    end
    %x{ say -r #{@rate} -v #{@voice} -o #{get_file_location} \"#{text}\" }
    begin
      %x{ open #{get_file_location} }
    rescue
      %x{ open #{@path + @filename + ".aiff"} }
    end
  end
end
