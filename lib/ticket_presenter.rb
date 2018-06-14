require "net/http"
require "openssl"
require "dotenv/load"
require "json"

class TicketPresenter
  def ticket_uri(ticket_number)
    URI("https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json")
  end

  def view_ticket(ticket_number)
    uri = ticket_uri(ticket_number)
    response = fetch_info(uri)
    convert(response)
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
end
