class Reader
  include Voices
  include Helpers::CliController
  include Helpers::CliOutputMethods
  # every instance of Reader can only have one document
  attr_reader :doc
  # `say` settings can be changed dynamically
  attr_accessor :rate, :voice, :path, :filename
  # default values are set for temporary files with default OSX voice at default rate (in word-per-minute)
  def initialize(url, rate=160, voice='Alex', path='/tmp/', ext='.aac')
    @url = url
    @doc = Nokogiri::HTML(open(url))
    @rate = rate
    @voice = voice
    @path = path
    @ext = ext
    # filename is created using a random object id as name
    @filename = Random.new.to_s.split(':')[1][0..-2]
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

  # Replaces newlines and escapes quotes in text
  def get_text
    @text = @title + @doc.text.gsub('\n', ' ').gsub('"', '\"')
    if @text
      true
    end
  end

  def get_file_location
    path + filename + @ext
  end

  def push_to_say
    match = Profile.any_matches?(@url)
    if match 
      text = Profile.send(match, @doc) 
    else
      sanitize_document
      get_text
      text = @text
    end
    # output is used to handle "Voice not found error"
    output = system "say -r #{@rate} -v #{@voice} -o #{get_file_location} \"#{text}\" "
    if !output
      # when voice not found print message and re-run custom_start
      voice_not_available(@voice)
      start(@url, custom_start(@rate))
      # false kills the previous "custom_start execution"
      false
    else
      begin
        %x{ open #{get_file_location} }
      rescue
        %x{ open #{@path + @filename + ".aiff"} }
      end
    end
  end
end
