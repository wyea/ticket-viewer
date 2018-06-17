require "net/http"
require "openssl"
require "dotenv/load"
require "json"
require "time"

class TicketPresenter
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

  def ticket_uri(ticket_number)
    URI("https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json")
  end

  def ticket_list_uri(path)
    URI(path)
  end

  def ticket_list_first_page
    "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
  end

  def record_was_not_found
    "The record wasn't found... Most likely, it was deleted "\
      "or you are from the future where it already exists."
  end

  def unauthorized
    "Ask your parents if you can go into the basement..."\
      "They must give you the right password."
  end
end
