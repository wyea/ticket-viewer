require "spec_helper"
require "ticket_presenter"
require "support/ticket_downloader"

RSpec.describe TicketPresenter do
  it_behaves_like TicketDownloader

  describe "#view_ticket" do
    let(:view_ticket) { subject.view_ticket(ticket_number) }

    context "ticket number is valid and authorization is successful" do
      let(:ticket_number) { "53" }

      it "returns a message that includes the ticket subject" do
        expect(view_ticket).to include(
          "Subject:        reprehenderit id non aliqua enim\n"
        )
      end
    end

    context "ticket number is invalid, but authorization is successful" do
      let(:ticket_number) { "1153" }

      it "returns a message saying that the record wasn't found" do
        expect(view_ticket).to eq(
          "The record wasn't found... Most likely, it was deleted "\
          "or you are from the future where it already exists."
        )
      end
    end

    context "ticket number is valid, but authorization is unsuccessful" do
      let(:ticket_number) { "53" }

      it "returns a message saying that authorization wasn't successful" do
        cached_password = ENV["PASSWORD"]
        ENV["PASSWORD"] = "aaaaa"
        expect(view_ticket).to eq(
          "Ask your parents if you can go into the basement..."\
          "They must give you the right password."
        )
        ENV["PASSWORD"] = cached_password
      end
    end
  end

  describe "#build_ticket_message" do
    let(:build_ticket_message) { subject.build_ticket_message(hash) }

    context "when the hash includes info about a ticket" do
      let(:hash) do
        {
          "ticket" =>
          {
            "url" => "https://anar.zendesk.com/api/v2/tickets/83.json",
            "id" => 83,
            "subject" => "anim Lorem reprehenderit Lorem esse",
            "status" => "open"
          }
        }
      end

      it "returns a message that includes the ticket subject" do
        expect(build_ticket_message).to include(
          "Subject:        anim Lorem reprehenderit Lorem esse\n"
        )
      end
    end

    context "when the hash does not include info about a ticket" do
      let(:hash) do
        { "berries" => %w[tomatos eggplants cucumbers] }
      end

      it "returns a message saying the hash doesn't include ticket info" do
        expect(build_ticket_message).to eq(
          "That server doesn't know anything about a ticket... :-("
        )
      end
    end
  end

  describe "#ticket_uri" do
    let(:ticket_uri) { subject.ticket_uri(ticket_number) }

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
end
