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
    # run setup
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
    
  end

end