require_relative "ticket_presenter"

class TicketCommander
  def initialize
    @ticket_presenter = TicketPresenter.new
  end

  def enter_command(command)
    unless validate_command(command)
      return "Invalid command: '#{command}'"
    end

    execute_command(command)
  end

  def validate_command(command)
    command_regex = if @ticket_presenter.multipage_mode
                      /\A(N|P|M)$\z/
                    else
                      /\A(A|T)((?<=A)$|(?<=T)\s[1-9]\d*)\z/
                    end
    command_regex =~ command
  end

  def execute_command(command)
    case command
    when "A"
      @ticket_presenter.view_ticket_list
    when /\AT\s[1-9]\d*\z/
      number = ticket_number(command)
      @ticket_presenter.view_ticket(number)
    when "N"
      @ticket_presenter.next_page
    when "P"
      @ticket_presenter.previous_page
    else
      # Main menu
    end
  end

  def ticket_number(command)
    command.split(" ").last
  end
end
