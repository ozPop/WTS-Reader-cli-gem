module Helpers
  
  module ClassMethods
    def process_headlines(headlines_with_url)
      output_hash = {}
      headlines_with_url.each_with_index do |data, index|
        output_hash[index+1] = [data[0], data[1]]
      end
      output_hash
    end
  end # end ClassMethods

  module CliController
    include Voices
    # LISTING ARTICLES

    # returns guardian tech section articles
    def list_sources
      sources = Profile.get_guardian_headlines
      # prints out numbered articles
      sources.each do |key, value|
        puts ColorizedString["#{key}."].red + " #{value[0]}"
      end
      # asks for input
      input = choose_source(sources)
      choice = sources[input][0]
      print ColorizedString["You have chosen:"].red
      puts ColorizedString[" #{choice}"].underline
      sources[input][1]
    end

    # helper method to collect input of desired article
    def choose_source(sources)
      input = nil
      until (1..sources.count).member?(input)
        puts ""
        puts ColorizedString["Please enter a number of desired article"].bold
        input = gets.chomp.to_i
      end
      input
    end

    # READER START

    # starts reader instance with defaults or custom settings
    def start(url, settings = nil)
      # default_start returns url and nil
      if settings == nil
        settings = load_settings
        Reader.new(url, settings[:rate], settings[:voice]).push_to_say
      # initialize Reader with custom settings
      elsif settings.class == Hash
        # depends on push_to_say to handle voice-not-found error
        if Reader.new(url, settings[:rate], settings[:voice]).push_to_say
          puts ""
          puts ColorizedString["Would you like to save these settings? (y)es or (n)o"].bold
          input = gets.chomp.downcase
          if input == "y" || input == "yes"
            save_settings(settings)
            puts ColorizedString["Settings saved to ~/.wts-reader/"].red.underline
          end
        end
      end
    end

    # default start uses defaults or loads saved settings and outputs details
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
      puts ColorizedString["Defaults: Language is #{language.capitalize}, " +
           "voice name is #{voice.capitalize}, rate is #{rate}"].bold
    end

    # collects custom settings: voice, rate
    def custom_start(rate = nil)
      settings = {}
      if rate == nil
        settings[:rate] = collect_rate_setting
      else
        settings[:rate] = rate
      end
      settings[:voice] = collect_voice_setting
      settings
    end

    # SAVING AND LOADING SETTINGS

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
        puts ColorizedString["Settings file (#{ENV["HOME"]}/.wts-reader/settings.txt) does not exist or has become corrupted. Creating new file with default settings"].red
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

    def collect_rate_setting
      legal_rate_range = 50..400
      display_suggested_rates
      puts ""
      puts ColorizedString["Please enter suggested or custom rate (50-400)"].bold
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
        puts ColorizedString["Please enter voice name or 'help' to see commands"].bold
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

    # takes in a hash and array. returns array with all hash internals
    # itterates (recursive) pusing all keys and values to given array
    def hash_to_array(hash, array)
      hash.each do |key, value|
        if value.class == Hash
          array << key.to_s
          hash_to_array(value, array)
        else
          array << key.to_s
          array << value
        end
      end
      array.flatten
    end
  end # end CliController

  module CliOutputMethods
    include Voices
    def greeting
      puts ColorizedString[" >>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<< "].blue
      print ColorizedString[" >>>"].blue
      print ColorizedString[" Welcome to Web To Speech Reader "].red.underline
      print ColorizedString["<<< \n"].blue
      puts ColorizedString[" >>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<< "].blue    
    end

    def first_steps
      puts ""
      puts ColorizedString["What do you want to do?"].red
      puts "  1. Enter my own URL"
      puts "  2. See available sources"
      puts ColorizedString["Please enter 1 or 2 otherwise type 'quit'"].bold
    end

    def cli_commands
      puts ""
      puts ColorizedString[" >>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<< "].blue
      puts ColorizedString["           Available commands:           "].red
      puts ColorizedString[" >>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<< "].blue    
      puts "Type 'languages' to view available languages"
      puts "Type 'english' to view available voice names"
      puts "Type 'rates' to view playback speed presets"
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
      puts ColorizedString[output].bold
    end

    def display_language_details(language)
      puts ""
      puts ColorizedString["#{language.capitalize}"].red.underline
      puts ""
      if VOICES[language.to_sym].class == Hash
        VOICES[language.to_sym].each do |country, voices|
          puts ColorizedString["#{country.to_s.capitalize}:"].red.underline
          display_columns(voices)
          puts ""
        end
      else
        display_columns(VOICES[language.to_sym])
      end
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
      puts ColorizedString[output].bold
    end

    def wrong_input
      puts ""
      puts ColorizedString["Unrecognized command. Please try again"].bold
    end

    def voice_not_available(voice)
      puts ""
      puts ColorizedString["The voice you entered needs to be downloaded."].red
      puts ColorizedString["Please use Dictation and Speech in preferences to download #{voice.capitalize} voice."].bold
    end

    def goodbye
      puts ""
      puts ColorizedString["Shutting down..."].red.underline
    end
  end # end CliOutputMethods

end