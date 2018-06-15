require "net/http"
require "openssl"
require "dotenv/load"
require "json"
require "time"

class TicketPresenter
  def ticket_uri(ticket_number)
    URI("https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json")
  end

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
      "This hash doesn't know anything about a ticket... :-("
    end
  end

  def fetch_info(uri)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(ENV["EMAIL_ADDRESS"], ENV["PASSWORD"])
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  def convert(response)
    if valid_json?(response.code)
      JSON.parse(response.body)
    end
  end

  def valid_json?(json)
    JSON.parse(json)
    true
  rescue JSON::ParserError
    false
  end

  def parse_time(time)
    Time.parse(time).httpdate if time.is_a?(String) && valid_time?(time)
  end

  def valid_time?(time)
    Time.parse(time)
    true
  rescue ArgumentError
    false
  end

  def record_was_not_found
    "The record wasn't found... Most likely, the ticket was deleted "\
      "or you are from the future where it already exists."
  end

  def unauthorized
    "Ask your parents if you can go into the basement..."\
      "They must give you the right password."
  end
end
