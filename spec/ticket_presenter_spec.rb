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

  describe "#view_ticket" do
    let(:view_ticket) { ticket_presenter.view_ticket(ticket_number) }

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
          "The record wasn't found... Most likely, the ticket was deleted "\
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
    let(:build_ticket_message) { ticket_presenter.build_ticket_message(hash) }

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
          "This hash doesn't know anything about a ticket... :-("
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

    context "when the address is invalid" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tiC_Cets/53.json") }

      it "returns Not Found" do
        expect(fetch_info.msg).to eq("Not Found")
      end

      it "returns code 404" do
        expect(fetch_info.code).to eq("404")
      end
    end

    context "when ticket number doesn't exist" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tickets/353.json") }

      it "returns Not Found" do
        expect(fetch_info.msg).to eq("Not Found")
      end

      it "returns code 404" do
        expect(fetch_info.code).to eq("404")
      end
    end

    context "when password is incorrect" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tickets/53.json") }

      it "returns Unauthorized" do
        cached_password = ENV["PASSWORD"]
        ENV["PASSWORD"] = "aaaaa"
        expect(fetch_info.msg).to eq("Unauthorized")
        ENV["PASSWORD"] = cached_password
      end

      it "returns code 401" do
        cached_password = ENV["PASSWORD"]
        ENV["PASSWORD"] = "aaaaa"
        expect(fetch_info.code).to eq("401")
        ENV["PASSWORD"] = cached_password
      end
    end
  end

  describe "#convert" do
    let(:convert)  { ticket_presenter.convert(response) }
    let(:response) { ticket_presenter.fetch_info(uri) }

    context "when the response is valid json" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tickets/53.json") }

      it "returns a hash" do
        expect(convert).to be_an_instance_of(Hash)
      end
    end
  end

  describe "#valid_json?" do
    let(:valid_json) { ticket_presenter.valid_json?(json) }

    context "when json is valid" do
      let(:json) do
        "{\"ticket\":{\"url\":\"https://anar.zendesk.com/"\
          "api/v2/tickets/53.json\",\"id\":53}}"
      end

      it "returns true" do
        expect(valid_json).to be true
      end
    end

    context "when json is invalid" do
      let(:json) { "I wish I was valid :(" }

      it "returns false" do
        expect(valid_json).to be false
      end
    end
  end

  describe "#parse_time" do
    let(:parse_time) { ticket_presenter.parse_time(time) }

    context "when time is valid" do
      let(:time) { "2018-06-06T03:20:10Z" }

      it "returns parsed time" do
        expect(parse_time).to eq("Wed, 06 Jun 2018 03:20:10 GMT")
      end
    end

    context "when time is invalid" do
      let(:time) { "I wish I was valid :(" }

      it "returns nil" do
        expect(parse_time).to be_nil
      end
    end

    context "when time nil" do
      let(:time) { nil }

      it "returns nil" do
        expect(parse_time).to be_nil
      end
    end

    context "when time not a string" do
      let(:time) { 5 }

      it "returns nil" do
        expect(parse_time).to be_nil
      end
    end
  end

  describe "#valid_time?" do
    let(:valid_time) { ticket_presenter.valid_time?(time) }

    context "when time is valid" do
      let(:time) { "2018-06-06T03:20:10Z" }

      it "returns true" do
        expect(valid_time).to be true
      end
    end

    context "when time is invalid" do
      let(:time) { "I wish I was valid :(" }

      it "returns false" do
        expect(valid_time).to be false
      end
    end
  end
end
