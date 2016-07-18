

## Handling Linux

determines if the kernel is `xnu` (OSX) or not (implied GNU Linux/BSD)
not used but possibly will be implemented for wider UNIX compatibility
```ruby
def set_speaker
  @reader = %x{ uname -v }.match(/root:xnu-\d+\.\d+/) ? "say" : "espeak"
end
```