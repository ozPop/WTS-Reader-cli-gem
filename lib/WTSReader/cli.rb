class WTSReader::Cli
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
    sources = WTSReader::Profile.get_guardian_headlines
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

  def start
    
  end

  def setup(url = nil)
    # TODO: Also allow to choose read speed
    languages_and_voices = hash_to_array(VOICES, arr = Array.new)
    legal_commands = ["1", "2", "languages", "quit"] + languages_and_voices
    input = nil
    until legal_commands.include?(input) == true
      puts ""
      puts "Choose from options below or input a command"
      puts "----------------------------------------------------------"
      puts "1. Use default WTSReader settings"
      puts "2. List available commands"
      puts "Type 1 or 2, otherwise just enter a command or type 'quit'"
      input = gets.chomp
    end
    case
    when input == "quit"
      return goodbye
    # set defaults, collect URL and start Reader
    when input == "1"
      puts ""
      puts "Defaults: Language is English, voice name is Alex, rate is 205"
      puts "Please enter URL:"
      url = gets.chomp
    # show commands and continue setup
    when input == "2"
      cli_commands
      setup
    when input == "languages"
      display_languages
    end
  end

  # collect keys from VOICES, format for display and output
  def display_languages
    languages = VOICES.keys
    output = ""
    languages.each_with_index do |language, index|
      # spaces to add inbetween = column.length - word.length
      output += "#{language.to_s + (" " * (12 - language.to_s.chars.count))}"
      if index % 4 == 0
        output += "\n"
      end
    end
    puts ""
    puts output
    setup
  end

  def start_reader(url, settings = nil)
    if settings == nil
      WTSReader::Reader.new(url).push_to_say
    else
      # initialize Reader with custom settings
    end
  end

  def cli_commands
    puts "Available commands:"
    puts "----------------------------------------------------------"
    puts "Type 'languages' to see available languages"
    puts "Type e.g.: 'english' to see available names for that language"
    puts "Typing name auto selects language (e.g.: 'tom' selects english)"
  end

  def goodbye
    puts ""
    puts "Shutting down..."
  end

end