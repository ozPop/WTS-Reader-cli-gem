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
      # start the setup
      setup
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

  # start reader instance with defaults or custom settings
  def start(type)
    # if type.class == String
      # then its default start
      # start_reader(type)
    # else it must be custom type
      # custom type will be handled differently
      # settings must be supplied into start_reader
      # start_reader(type, settings)
    #end
  end

  def setup(url = nil)
    # TODO: Also allow to choose read speed
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
    # displays defaults, collects URL and starts Reader with defaults
    when input == "1"
      start(default_start)
    # custom start collects rate and voice choice
    when input == "2"
      settings = custom_start
    # show commands
    when input == "3"
      cli_commands
      setup
    # display language choices
    when input == "languages"
      display_columns(languages)
      setup
    when input == "rates"
      display_suggested_rates
      setup
    # display names associated with a particular language
    when languages.include?(input)
      language_details(input)
      setup
    end
  end

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

  def default_start
    puts ""
    puts "Defaults: Language is English, voice name is Alex, rate is 160"
    puts "Please enter URL:"
    url = gets.chomp
  end

  # collects custom settings: voice, rate
  def custom_start
    rate = collect_rate_setting
  end

  # collect keys from VOICES
  def languages
    array = []
    VOICES.each_key {|key| array << key.to_s}
    array
  end

  def language_details(language)
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

  # output columns
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

  def start_reader(url, settings = nil)
    if settings == nil
      Reader.new(url).push_to_say
    else
      # initialize Reader with custom settings
    end
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