require_relative "ticket_commander"

def menu
  puts "* Press Ctrl-D to exit."
  puts "* Type 'A' to see a list of tickets"
  puts "* Type 'T ###' (where ### is a ticket number: 'T 1', 'T 53', etc.),"
  puts "  make sure there is a space between the 'T' and the number"
  puts "  and press Enter/Return to see an individual ticket."
  puts
  print "Now, tell me what to do, master: "
end

ticket_commander = TicketCommander.new

command = ""

# If user presses Ctrl-D (= nil) the loop stops executing
while command
  menu
  command = gets
  if command
    message = ticket_commander.enter_command(command.upcase.chomp)
    puts message if message
  end
end
