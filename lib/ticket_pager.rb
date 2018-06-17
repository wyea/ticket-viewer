require_relative "ticket_downloader"

class TicketPager
  include TicketDownloader

  attr_accessor :multipage_mode
  attr_reader   :number_of_pages

  def initialize
    @multipage_mode  = false
    @previous_page   = ""
    @next_page       = ""
    @number_of_pages = 0
  end

  def view_ticket_list(path = ticket_list_first_page)
    uri = ticket_list_uri(path)
    response = fetch_info(uri)
    if response.msg == "OK"
      hash = convert(response)
      build_ticket_list(hash)
    elsif response.msg == "Not Found"
      record_was_not_found
    elsif response.msg == "Unauthorized"
      unauthorized
    end
  end

  def build_ticket_list(hash)
    if hash["tickets"] && hash["tickets"].any?
      ticket_list = hash["tickets"].reduce([]) do |list, ticket|
        list.push(
          ticket["id"].to_s.rjust(4) + " | " +
          ticket["status"].to_s.ljust(8) + " | " +
          parse_time(ticket["updated_at"]).to_s.ljust(29) + " | " +
          ticket["subject"].to_s.ljust(68) + "\n"
        )
      end
      paginate(hash)
      ticket_list_header + ticket_list.join("")
    else
      "The server doesn't know anything about "\
        "the page you want to see... :-("
    end
  end

  def paginate(hash)
    @multipage_mode  =  hash["next_page"] ? true : false
    @next_page       =  hash["next_page"] || ""
    @previous_page   =  hash["previous_page"] || ""
    @number_of_pages = (hash["count"].to_f / 25).ceil
  end

  def next_page
    unless @next_page.empty?
      view_ticket_list(@next_page)
    else
      record_was_not_found
    end
  end

  def previous_page
    unless @previous_page.empty?
      view_ticket_list(@previous_page)
    else
      record_was_not_found
    end
  end

  def ticket_list_header
    "id".rjust(4) + " | " +
      "Status".ljust(8) + " | " +
      "Last updated".ljust(29) + " | " +
      "Subject".ljust(68) + "\n " +
      "-" * 112 + "\n"
  end

  def ticket_list_uri(path)
    URI(path)
  end

  def ticket_list_first_page
    "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
  end
end
