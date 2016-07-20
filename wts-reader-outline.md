# WTS-Reader Project Details

## Workload breakdown

### Ozzie
* Create a starting Readme.md
* Write project details
* Create a data structure modelded after text-to-speech languages and voices
* Write CLI user exprerience:
    * Various display prompts to guide user through the program
        * Collecting web address or giving a list of article choices
        * Allowing to choose default settings or customized playback settings
        * Help commands to view available languages, voices, suggested rates
* Refactoring overall project structure
    * Write helper methods to control outputs

  
### Blaze
* Setup the main Reader and Profile class
    * Reader responsible for web document parsing and interfacing with say
    * Profile responsible for handling specific web content
* Web page parsing and sanitization
    * Removal of various web page formating noise
* Reader class intefacing with text-to-speech (built-in say program)
    * Start text-to-speech with provided settings
* Implement settings saving and loading
* Handling of audio files

----

## Dependencies

----

* Nokogiri
* OpenURI
* Colorize

## Rough Program Flow

----

1. Greet and prompt user to input web address or to view available sources
    * Available sources lists guardian tech articles
2. Gem scrapes the web page or chosen article
    * It cleanses the content of all intrusive noise leaving only target content
3. The gem initializes with default settings (e.g.: Engish, Voice-name, Read-speed)
    * Gives the user options to run with defaults or customize settings
        * If user chooses to customize
            * User is promted to choose the rate of speech (wpm)
            * User can choose a different language and voice
4. Upon choosing defaults or customizing settings
    * The program initializes the say program with provided settings
5. Gem opens system default media player
6. Gives an option to permanently save chosen custom settings
7. Stores the audio file in /tmp and lets the system handle the file

