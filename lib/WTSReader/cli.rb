class Cli
  include Voices
  include Helpers::CliController
  include Helpers::CliOutputMethods

  def call
    greeting
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
end
