require_relative "ticket_downloader"

class TicketPresenter
  include TicketDownloader

  def view_ticket(ticket_number)
    uri = ticket_uri(ticket_number)
    response = fetch_info(uri)
    if response.msg == "OK"
      hash = convert(response)
      build_ticket_message(hash)
    elsif response.msg == "Not Found"
      record_was_not_found
    elsif response.msg == "Unauthorized"
      unauthorized
    end
  end

  def build_ticket_message(hash)
    if hash["ticket"]
      "Ticket #{hash['ticket']['id']}:\n"\
        "Date created:   #{parse_time(hash['ticket']['created_at'])}\n"\
        "Last updated:   #{parse_time(hash['ticket']['updated_at'])}\n"\
        "Current status: #{hash['ticket']['status']}\n"\
        "Subject:        #{hash['ticket']['subject']}\n"\
        "Description:    #{hash['ticket']['description']}"
    else
      "That server doesn't know anything about a ticket... :-("
    end
  end

  def ticket_uri(ticket_number)
    URI("#{ENV['API_URL']}tickets/#{ticket_number}.json")
  end
end
