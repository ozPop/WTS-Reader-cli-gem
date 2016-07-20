class Cli
  include Voices
  include Helpers::InstanceMethods

  def call
    # start the reader
    puts "   >>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<   "
    puts " >>> Welcome to Web To Speech Reader <<<"
    puts "   >>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<   "
    input = nil
    until input == "1" || input == "2" || input == "quit"
      first_steps
      input = gets.chomp
    end
    case
    when input == "quit"
      goodbye
    when input == "1"
      puts ""
      puts "Please enter a web address"
      url = gets.chomp
      setup(url)
    when input == "2"
      # show user list of available read sources and collects URL choice
      url = list_sources
      setup(url)
    end
  end

  def first_steps
    puts ""
    puts "What do you want to do?"
    puts "  1. Enter my own URL"
    puts "  2. See available sources"
    puts "Please enter 1 or 2 otherwise type 'quit'"
  end

  def list_sources
    sources = Profile.get_guardian_headlines
    # prints out numbered articles
    sources.each do |key, value|
      puts "#{key}. #{value[0]}"
    end
    # asks for input
    input = choose_source(sources)
    choice = sources[input][0]
    puts "You have chosen: #{choice}"
    sources[input][1]
  end

  # helper method to collect input of desired article
  def choose_source(sources)
    input = nil
    until (1..sources.count).member?(input)
      puts ""
      puts "Please enter a number of desired article"
      input = gets.chomp.to_i
    end
    input
  end

  def setup(url)
    languages_and_voices = hash_to_array(VOICES, arr = Array.new)
    legal_commands = ["1", "2", "3", "languages", "rates", "quit"] +
      languages_and_voices
    input = nil
    until legal_commands.include?(input) == true
      puts ""
      puts "Choose from options below or input a command"
      puts "----------------------------------------------------------"
      puts "1. Use default WTSReader settings"
      puts "2. Enter custom WTSReader settings"
      puts "3. List available commands"
      puts "Type 1, 2, or 3 otherwise just enter a command or type 'quit'"
      input = gets.chomp.downcase
    end
    case
    when input == "quit"
      return goodbye
    # loads personalized defaults otherwise original defaults
    # displays defaults, collects URL and starts Reader with defaults
    when input == "1"
      start(url, default_start)
    # custom_start collects rate and voice choice
    when input == "2"
      start(url, custom_start)
    when input == "3"
      cli_commands
      setup(url)
    when input == "languages" || languages.include?(input) || input == "rates"
      display_helper(input)
      setup(url)
    end
  end

  def display_helper(input)
    case
    when input == "languages"
      display_columns(languages)
    when languages.include?(input)
      # country varieties (if any) and voice names
      display_language_details(input)
    when input == "rates"
      display_suggested_rates
    end
  end

  # APP START

  # start reader instance with defaults or custom settings
  def start(url, settings = nil)
    # default_start returns url and nil
    if settings == nil
      settings = load_settings
      Reader.new(url, settings[:rate], settings[:voice]).push_to_say
    # initialize Reader with custom settings
    elsif start_type.class == Hash
      Reader.new(url, settings[:rate], settings[:voice]).push_to_say
      puts ""
      puts "Would you like to save these settings? (y)es or (n)o"
      input = gets.chomp.downcase
      if input == "y" || input == "yes"
        save_settings(settings)
        puts "Settings saved to ~/.wts-reader/"
      end
    end
  end

  # default start uses settings to output details about defaults
  def default_start
    settings = load_settings
    rate = settings[:rate]
    voice = settings[:voice].downcase
    language = nil
    VOICES.each do |key, value|
       if value.class == Hash
          value.each_value {|array| language = key.to_s if array.include?(voice)}
       else
          language = key.to_s if value.include?(voice)
      end
    end
    puts ""
    puts "Defaults: Language is #{language.capitalize}, " +
         "voice name is #{voice.capitalize}, rate is #{rate}"
  end

  # collects custom settings: voice, rate
  def custom_start
    settings = {}
    settings[:rate] = collect_rate_setting
    settings[:voice] = collect_voice_setting
    settings
  end

  # make settings dir unless it exists
  # write to settings.txt the desired settings
  def save_settings(settings)
    %x{ mkdir #{ENV["HOME"]}/.wts-reader } unless File.directory?("#{ENV["HOME"]}/.wts-reader")
    File.open(ENV["HOME"] + "/.wts-reader/settings.txt", 'w') do |file| 
      file.write("Rate:#{settings[:rate]}\nVoice:#{settings[:voice]}\nPath:#{settings[:path] || '/tmp/'}\n")
    end
  end

  # loading settings and handling load error
  def load_settings
    settings = {}
    begin
      text = IO.readlines(ENV["HOME"] + "/.wts-reader/settings.txt", 'r')[0]
      settings[:rate] = text.match(/Rate:(\w+)\n/).captures[0].to_i
      settings[:voice] = text.match(/Voice:(\w+)\n/).captures[0]
      settings[:path] = text.match(/Path:(.+)\n/).captures[0]
      settings
    rescue
      settings = {:rate => 160, :voice => "Alex", :path => '/tmp/'}
      save_settings(settings)
      puts "Settings file (#{ENV["HOME"]}/.wts-reader/settings.txt) does not exist or has become corrupted. Creating new file with default settings"
      settings
    end
  end

  # RATES

  def suggested_rates
    rates = {
      "0.5x" => 80,
      "1x" => 160,
      "1.5x" => 240,
      "2x" => 320
    }
  end

  def display_suggested_rates
    puts ""
    output = ""
    suggested_rates.each do |rate, value|
      output += "#{rate} "
      output += "speed is #{value}/wpm"
      output += "(default)" if value == 160
      output += "\n"
    end
    puts output
  end

  def collect_rate_setting
    legal_rate_range = 50..400
    display_suggested_rates
    puts ""
    puts "Please enter suggested or custom rate (50-400)"
    input = nil
    until legal_rate_range.member?(input)
      input = gets.chomp.to_i
      puts "check input" if legal_rate_range.member?(input) == false
    end
    input
  end

  # VOICE

  def voices
    all_voices = []
    VOICES.each_value do |value|
      if value.class == Hash
        all_voices << value.flatten(2).delete_if {|el| el.class == Symbol}
      else
        all_voices << value
      end
    end
    all_voices.flatten
  end
  
  def collect_voice_setting
    input = nil
    until voices.include?(input)
      if input == "help"
        cli_commands
      elsif input == "languages" || languages.include?(input) || input == "rates"
        display_helper(input)
      end
      puts ""
      puts "Please enter voice name or 'help' to see commands"
      input = gets.chomp.downcase
    end
    input
  end

  # LANGUAGES

  def languages
    array = []
    VOICES.each_key {|key| array << key.to_s}
    array
  end

  def display_language_details(language)
    puts ""
    puts "#{language.capitalize}"
    puts "----------------------------------------------------------"
    if VOICES[language.to_sym].class == Hash
      VOICES[language.to_sym].each do |country, voices|
        puts "#{country.to_s.capitalize}:"
        display_columns(voices)
        puts ""
      end
    else
      display_columns(VOICES[language.to_sym])
    end
  end

  # expects an array, outputs elements in columns
  def display_columns(input)
    output = ""
    input.each_with_index do |element, index|
      # spaces to add inbetween = column.length - word.length
      output += "#{element.capitalize + (" " * (15 - element.to_s.chars.count))}"
      if index % 4 == 0 && index != 0
        output += "\n"
      end
    end
    puts ""
    puts output
  end

  def cli_commands
    puts ""
    puts "Available commands:"
    puts "----------------------------------------------------------"
    puts "Type 'languages' to view available languages"
    puts "Type 'english' to view available voice names"
    puts "Type 'rates' to view playback speed presets"
  end

  def goodbye
    puts ""
    puts "Shutting down..."
  end

end
