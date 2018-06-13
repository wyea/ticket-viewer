require "net/http"
require "openssl"
require "dotenv/load"
require "json"

class TicketPresenter
  def ticket_uri(ticket_number)
    URI("https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json")
  end

  def fetch_info(uri)
    request = Net::HTTP::Get.new(uri)
    request.basic_auth(ENV["EMAIL_ADDRESS"], ENV["PASSWORD"])
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      http.request(request)
    end
  end

  def convert(response)
    if response.code == "200"
      JSON.parse(response.body)
    end
  end
end
