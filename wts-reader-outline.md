# WTS-Reader Project Details

## Workload breakdown

Ozzie
* Create a starting Readme.md
* Write project details
* Write CLI user exprerience such as
    * greetting the user
    * giving lang and voice choices

  
Blaze
* add coding done so far
    * HTML sanitization to Reader class
    * Reader class intefacing with text-to-speech
    * 

----

## Dependencies

----

* Nokogiri
* OpenURI

## Rough Program Flow

----

1. Prompt user to input URL or type "View available sources"
    * Available sources lists site choices
        * Lists available articles
2. Gem scrapes the URL or Article
  * Cleanses the content of the URL and prepares to send
3. Shows the user default settings (e.g.: Engish, Voice-name, Read-speed) and asks if to play with default or change settings
    * If user wants to change settings
        * Choose different language
            * Show available voices
        * Allow user to change read-speed
4. Push the data to the say program
5. Open with default media player
6. Give an option to permanently save the file (promting user for a path)
7. Asks user if she wants to start another wts-read session

## Expanding on above points

----

### 3. Handling Language and Voice

* Store the language and voice name relationships in a hash
* On command return a list of available languages and voices
* They can either put in the langugage they want it spoken in with a default voice or choose another voice
* They can put the name of the voice and language is auto set
    * Create a hash that stores all lang and voice choices 
        * All available Languages and names: prefrerences > Dictation & speech > text to speech > system voices select > customize
        * Example hash: voices = {chinese => [tik tak toe]}

### Handling files

  * Save all files to /tmp and that takes care of space management automatically


### Text to speech software access usding command line

OS X
* use 'say' command to use the software
* 'man say' to see manual

Ruby
* %x{ say "Hello world." }

Linux
* possibly add support after we get OS X down
