begin
  require "dotenv/load"
rescue LoadError
  puts "* Hey, make sure you took care about the environment variables!!!\n"
end
require "json"
require "net/http"
require "openssl"
require "time"

require_relative "ticket_commander"

def general_menu
  puts "* Press Ctrl-D to exit."
  puts "* Type 'A' to see a list of tickets"
  puts "* Type 'T ###' (where ### is a ticket number: 'T 1', 'T 53', etc.),"
  puts "  make sure there is a space between the 'T' and the number"
  puts "  and press Enter/Return to see an individual ticket."
  puts
end

def paginator_menu
  puts "* Press Ctrl-D to exit."
  puts "* Type 'N' to see the next page."
  puts "* Type 'P' to see the previous page."
  puts "* Type 'M' to go back to the main menu."
  puts
end

ticket_commander = TicketCommander.new

command = ""

# If user presses Ctrl-D (= nil) the loop stops executing
while command
  ticket_commander.multipage_mode ? paginator_menu : general_menu
  print "Now, tell me what to do, master: "
  command = gets
  if command
    message = ticket_commander.enter_command(command.upcase.chomp)
    puts message if message
  end
end
