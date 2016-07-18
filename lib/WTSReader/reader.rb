class WTSReader::Reader
  # every instance of Reader can only have one document
  attr_reader :doc
  # `say` settings can be changed dynamically
  attr_accessor :rate, :voice, :path, :filename
  # default values are set for temporary files with default OSX voice at default rate (in word-per-minute)
  def initialize(url, rate=205, voice='Alex', path='/tmp/', ext='.aac')
    @url = url

    @doc = Nokogiri::HTML(open(url))
    @rate = rate
    @voice = voice
    @path = path
    @ext = ext
    # filename is created using a random object id as name
    @filename = Random.new.to_s.split(':')[1][0..-2]
  end

  # NOTE: text will likely get removed in future
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
  # replaces newlines and escapes quotes in text
  def get_text
    @text = @title + @doc.text.gsub('\n', ' ').gsub('"', '\"')
    if @text
      true
    end
  end

  ## INTERFACE WITH SAY
  # execute: creating dir and saving settings
  def save_settings
    %x{ mkdir #{ENV["HOME"]}/.wts-reader } unless File.directory?("#{ENV["HOME"]}/.wts-reader")
    File.open(ENV["HOME"] + "/.wts-reader/settings.txt", 'w') {|file| file.write("Voice:#{@voice}\nRate:#{@rate}\nPath:#{@path}\n")}
  end

  # loading of settings and handling load error
  def load_settings
    begin
      text = IO.readlines(ENV["HOME"] + "/.wts-reader/settings.txt", 'r')[0]
      @voice = text.match(/Voice:(\w+)\n/).captures[0]
      @rate = text.match(/Rate:(\w+)\n/).captures[0].to_i
      @path = text.match(/Path:(.+)\n/).captures[0]
    rescue
      save_settings
      "Settings file (#{ENV["HOME"]}/.wts-reader/settings.txt) does not exist or has become corrupted. Creating new file with default settings"
    end
  end

  # sets the voice manually. this will have to be built out with the cli
  def set_voice(voice)
    # Hash of {:language => [voice1, voice2, ...], language2 => [...], ...} goes here
    @voice = voice
  end

  def set_speed(rate)
    # allows user to set words-per-minute manually
    return @rate = rate if rate.is_a?(Integer)
    # otherwise gives user-friendly options
    # NOTE: the below line will probably be moved to the CLI class
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
      text = WTSReader::Profile.send(match, @doc) 
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
