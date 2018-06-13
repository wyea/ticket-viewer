require "spec_helper"
require "ticket_presenter"

RSpec.describe TicketPresenter do
  let(:ticket_presenter) { TicketPresenter.new }

  describe "#ticket_uri" do
    let(:ticket_uri) { ticket_presenter.ticket_uri(ticket_number) }

    context "when the ticket number is 1" do
      let(:ticket_number) { "1" }

      it "returns uri for ticket # 1" do
        expect(ticket_uri.path).to eq(
          "/api/v2/tickets/1.json"
        )
      end
    end

    context "when the ticket number is 53" do
      let(:ticket_number) { "53" }

      it "returns uri for ticket # 53" do
        expect(ticket_uri.path).to eq(
          "/api/v2/tickets/53.json"
        )
      end
    end
  end

  describe "#fetch_info" do
    let(:fetch_info) { ticket_presenter.fetch_info(uri) }

    context "when the address is valid" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tickets/53.json") }

      it "returns OK" do
        expect(fetch_info.msg).to eq("OK")
      end

      it "returns code 200" do
        expect(fetch_info.code).to eq("200")
      end
    end
  end

  describe "#convert" do
    let(:convert)  { ticket_presenter.convert(response) }
    let(:response) { ticket_presenter.fetch_info(uri) }

    context "when the address is valid" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tickets/53.json") }

      it "returns a hash" do
        expect(convert).to be_an_instance_of(Hash)
      end
    end
  end
end
