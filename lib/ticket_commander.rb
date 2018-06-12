class TicketCommander
  def enter_command(command)
    unless validate_command(command)
      return "Invalid command: '#{command}'"
    end

    execute_command(command)
  end

  def validate_command(command)
    command_regex = /\A(A|T)((?<=A)$|(?<=T)\s[1-9]\d*)\z/
    command_regex =~ command
  end

  def execute_command(command)
    if /\AT\s[1-9]\d*\z/ =~ command
      # implement a view_a_ticket method 
    end
  end

  def ticket_number(command)
    command.split(" ").last
  end
end
