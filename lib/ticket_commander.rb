class TicketCommander
  def validate_command(command)
    command_regex = /\A(A|T)((?<=A)$|(?<=T)\s[1-9]\d*)\z/
    command_regex =~ command
  end
end
