class Cli
  include Voices
  include Helpers::CliController
  include Helpers::CliOutputMethods

  def call
    greeting
    input = nil
    legal_commands = ["1", "2", "quit"]
    until legal_commands.include?(input)
      first_steps
      input = gets.chomp
      wrong_input if !legal_commands.include?(input)
    end
    case
    when input == "quit"
      goodbye
    when input == "1"
      url = validate_input
      if url == "quit"
        call
      else
        setup(url)
      end
    when input == "2"
      # show user list of available read sources and collects URL choice
      url = list_sources
      setup(url)
    end
  end

  def setup(url)
    legal_commands = ["1", "2", "3", "languages", "rates", "quit"] +
      languages
    input = nil
    until legal_commands.include?(input)
      puts ""
      puts ColorizedString["Choose from options below or input a command"].red.underline
      puts ""
      puts "1. Use default WTSReader settings"
      puts "2. Enter custom WTSReader settings"
      puts "3. List available commands"
      puts ColorizedString["Type 1, 2, or 3 otherwise enter a command or type 'quit'"].bold
      input = gets.chomp.downcase
      wrong_input if !legal_commands.include?(input)
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
