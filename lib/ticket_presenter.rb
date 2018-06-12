class TicketPresenter
  def ticket_uri(ticket_number)
    URI("https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json")
  end
end
