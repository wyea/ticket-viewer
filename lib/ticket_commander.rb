require_relative "ticket_presenter"
require_relative "ticket_pager"

class TicketCommander
  def initialize
    @ticket_presenter = TicketPresenter.new
    @ticket_pager     = TicketPager.new
  end

  def enter_command(command)
    unless validate_command(command)
      return "Invalid command: '#{command}'"
    end

    execute_command(command)
  end

  def validate_command(command)
    command_regex = if @ticket_pager.multipage_mode
                      /\A(N|P|M)$\z/
                    else
                      /\A(A|T)((?<=A)$|(?<=T)\s[1-9]\d*)\z/
                    end
    command_regex =~ command
  end

  def execute_command(command)
    case command
    when "A"
      @ticket_pager.view_ticket_list
    when "N"
      @ticket_pager.next_page
    when "P"
      @ticket_pager.previous_page
    when /\AT\s[1-9]\d*\z/
      number = ticket_number(command)
      @ticket_presenter.view_ticket(number)
    else
      general_mode
    end
  end

  def ticket_number(command)
    command.split(" ").last
  end

  def multipage_mode
    @ticket_pager.multipage_mode
  end

  def general_mode
    @ticket_pager.multipage_mode = false
  end
end
