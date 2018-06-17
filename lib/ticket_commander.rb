require_relative "ticket_presenter"

class TicketCommander
  def initialize
    @ticket_presenter = TicketPresenter.new
    @multipage_mode   = @ticket_presenter.multipage_mode
  end

  def enter_command(command)
    unless validate_command(command)
      return "Invalid command: '#{command}'"
    end

    execute_command(command)
  end

  def validate_command(command)
    command_regex = if @multipage_mode
                      /\A(N|P|M)$\z/
                    else
                      /\A(A|T)((?<=A)$|(?<=T)\s[1-9]\d*)\z/
                    end
    command_regex =~ command
  end

  def execute_command(command)
    if /\AA$\z/ =~ command
      @ticket_presenter.view_ticket_list
    elsif /\AT\s[1-9]\d*\z/ =~ command
      number = ticket_number(command)
      @ticket_presenter.view_ticket(number)
    end
  end

  def ticket_number(command)
    command.split(" ").last
  end
end
