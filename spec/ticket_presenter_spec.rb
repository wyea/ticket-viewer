require "spec_helper"
require "ticket_presenter"

RSpec.describe TicketPresenter do
  let(:ticket_presenter) { TicketPresenter.new }

  describe "#ticket_url" do
    let(:ticket_url) { ticket_presenter.ticket_url(ticket_number) }

    context "when the ticket number is 1" do
      let(:ticket_number) { "1" }

      it "returns url for ticket # 1" do
        expect(ticket_url).to eq(
          "https://anar.zendesk.com/api/v2/tickets/1.json"
        )
      end
    end

    context "when the ticket number is 53" do
      let(:ticket_number) { "53" }

      it "returns url for ticket # 53" do
        expect(ticket_url).to eq(
          "https://anar.zendesk.com/api/v2/tickets/53.json"
        )
      end
    end
  end
end


class TicketPresenter
  def ticket_url(ticket_number)
    "https://anar.zendesk.com/api/v2/tickets/#{ticket_number}.json"
  end
end
