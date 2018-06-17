module TicketDownloader
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
    "The record wasn't found... Most likely, it was deleted "\
      "or you are from the future where it already exists."
  end

  def unauthorized
    "Ask your parents if you can go into the basement..."\
      "They must give you the right password."
  end
end
