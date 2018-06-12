class TicketPresenter
  def ticket_url(ticket_number)
    "https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json"
  end
end
