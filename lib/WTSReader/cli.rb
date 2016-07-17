class WTSReader::Cli
  include Voices

  def call
    # start the reader
    puts ">>>>>>>>>>>>>>>><<<<<<<<<<<<<<<"
    puts "Welcome to Web To Speech Reader"
    puts ">>>>>>>>>>>>>>>><<<<<<<<<<<<<<<"
    input = nil
    until input == "1" || input == "2"
      first_steps
      input = gets.chomp
    end
    case
    when input == "1"
      # start the main application
      start
    when input == "2"
      # show user list of available read sources
      list_sources
    end
  end

  def start
    setup
  end

  def first_steps
    puts ""
    puts "What do you want to do?"
    puts "  1. Enter my own URL"
    puts "  2. See available sources"
    puts "Please enter 1 or 2"
  end

  def list_sources
    # TODO: build this method to list available sources
    puts "listing sources"
  end

  def setup
    # TODO: legal commands will be expanded to include all language names and voice names
    # TODO: Also allow to choose read speed
    legal_commands = ["1", "2", "languages", "quit"]
    input = nil
    until legal_commands.include?(input) == true
      puts ""
      puts "Choose from options below or input a command"
      puts "1. Use default settings"
      puts "2. List commands"
      puts "Type 1 or 2, otherwise just enter a command or type 'quit'"
      input = gets.chomp
    end
    case
    when input == "quit"
      return goodbye
    # set defaults
    when input == "1"
      puts ""
      puts "Language is English, Voice Name is Alex, Rate is 205"
    # show commands and continue setup
    when input == "2"
      cli_commands
      setup
    end
  end

  def cli_commands
    puts ""
    puts "Type 'languages' to see available languages"
    puts "Type e.g.: 'english' to see available voice names for that language"
    puts "Type 'tom' to make your choice"
  end

  def goodbye
    puts "Shutting down"
  end

end