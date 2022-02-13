#!/usr/bin/ruby

# Change the path if necessary. Note, the last char must be '/'.
SCREEN_PREFIX = "/sys/class/backlight/intel_backlight/"
KEYBOARD_PREFIX = "/sys/class/leds/smc::kbd_backlight/"

if ARGV.size != 2 ||
   (ARGV[0] != "screen" && ARGV[0] != "keyboard") || # action
   (ARGV[1][0] != '+' && ARGV[1][0] != '-') # delta value to adjust brightness level
  puts """usage: macbl.rb [screen|keyboard] [+,-]<number>

  examples: 
    macbl.rb screen -500 #decrease screen's brightness at 500 units
    macbl.rb screen +100 #increase screen's brightness at 100 units

  Utility to adjust the brightness of the screen or keyboard of a
  macbook running Linux.

  Ricardo Cosme <r@cosme.im> [Tested on a MacBook Air Mid 2013 13\" running Arch Linux]"""
  exit
end

target = ARGV[0] # screen or keyboard
action = ARGV[1][0] # + or -
amount = ARGV[1].to_i # numeric value

filenames = ["max_brightness", "brightness"].map { |filename|
  eval("#{target.upcase}_PREFIX") + filename }
max_filename, actual_filename = filenames

max, actual = filenames.map { |filename| File.read(filename).to_i }

File.open(actual_filename, "w") { |fh|
  new_brightness = actual + amount
  
  # the new value must be between [0, max]
  new_brightness = [0, [new_brightness, max].min].max
  
  puts "adjusting brightness from #{actual} to #{new_brightness} [max:#{max}]"
  fh.write new_brightness
}
