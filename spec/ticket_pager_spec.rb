require "spec_helper"
require "ticket_pager"
require "support/ticket_downloader"

RSpec.describe TicketPager do
  it_behaves_like TicketDownloader

  describe "#view_ticket_list" do
    let(:view_ticket_list) { subject.view_ticket_list(path) }

    context "when the address is correct and authorization is successful" do
      let(:path) do
        "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
      end

      it "returns a string with a ticket list" do
        expect(view_ticket_list).to include(
          "7 | open     | Wed, 06 Jun 2018 03:19:57 GMT | "\
          "cillum quis nostrud labore amet"
        )
      end
    end

    context "when the address is incorrect, but authorization successful" do
      let(:path) do
        "https://anar.zendesk.com/api/v2/tic_ke_ts.js_on"
      end

      it "returns a message saying that the record wasn't found" do
        expect(view_ticket_list).to eq(
          "The record wasn't found... Most likely, it was deleted "\
          "or you are from the future where it already exists."
        )
      end
    end

    context "when the address is correct, but authorization unseccessful" do
      let(:path) do
        "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
      end

      it "returns a message saying that authorization wasn't successful" do
        cached_password = ENV["PASSWORD"]
        ENV["PASSWORD"] = "aaaaa"
        expect(view_ticket_list).to eq(
          "Ask your parents if you can go into the basement..."\
          "They must give you the right password."
        )
        ENV["PASSWORD"] = cached_password
      end
    end
  end

  describe "#build_ticket_list" do
    let(:build_ticket_list) { subject.build_ticket_list(hash) }

    context "when the hash includes info about tickets" do
      let(:hash) do
        {
          "tickets" =>
          [
            {
              "id" => 83,
              "updated_at" => "2018-06-06T03:20:02Z",
              "subject" => "anim Lorem reprehenderit Lorem esse",
              "status" => "open"
            },
            {
              "id" => 32,
              "updated_at" => "2018-06-10T09:25:32Z",
              "subject" => "La la la",
              "status" => "closed"
            }
          ]
        }
      end

      it "returns a message that includes a ticket's subject" do
        expect(build_ticket_list).to include(
          "anim Lorem reprehenderit Lorem esse"
        )
      end

      it "returns a message that includes a ticket's status" do
        expect(build_ticket_list).to include(
          "closed"
        )
      end

      it "returns a message that includes the header" do
        expect(build_ticket_list).to include(
          "id | Status   | Last updated"
        )
      end
    end

    context "when the hash does not include info about tickets" do
      let(:hash) do
        { "berries" => %w[tomatos eggplants cucumbers] }
      end

      it "returns a message saying the hash doesn't include ticket info" do
        expect(build_ticket_list).to eq(
          "The server doesn't know anything about "\
          "the page you want to see... :-("
        )
      end
    end
  end

  describe "#multipage_mode" do
    let(:multipage_mode)   { subject.multipage_mode }
    let(:view_ticket_list) { subject.view_ticket_list(path) }
    let(:path) do
      "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
    end

    context "when no pages were seen yet" do
      it "returns false" do
        expect(multipage_mode).to be false
      end
    end

    context "when view_ticket_list was already executed" do
      it "returns true if there is next page" do
        view_ticket_list
        expect(multipage_mode).to be true
      end
    end
  end

  describe "#next_page" do
    let(:next_page) { subject.next_page }
    let(:view_ticket_list) { subject.view_ticket_list(path) }
    let(:path) do
      "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
    end

    context "when view_ticket_list wasn't executed yet" do
      it "returns a message saying that the record wasn't found" do
        expect(next_page).to eq(
          "The record wasn't found... Most likely, it was deleted "\
          "or you are from the future where it already exists."
        )
      end
    end

    context "when view_ticket_list was executed once" do
      it "returns second page that include the following text" do
        view_ticket_list
        expect(next_page).to include(
          "officia esse nostrud est exercitation"
        )
      end
    end
  end

  describe "#previous_page" do
    let(:previous_page) { subject.previous_page }
    let(:view_ticket_list) { subject.view_ticket_list(path) }
    let(:path) do
      "https://anar.zendesk.com/api/v2/tickets.json?page=1&per_page=25"
    end

    context "when view_ticket_list wasn't executed yet" do
      it "returns a message saying that the record wasn't found" do
        expect(previous_page).to eq(
          "The record wasn't found... Most likely, it was deleted "\
          "or you are from the future where it already exists."
        )
      end
    end

    context "when we are on the first page and there is no previous one" do
      it "returns a message saying that the record wasn't found" do
        view_ticket_list
        expect(previous_page).to eq(
          "The record wasn't found... Most likely, it was deleted "\
          "or you are from the future where it already exists."
        )
      end
    end
  end

  describe "#ticket_list_header" do
    let(:ticket_list_header) { subject.ticket_list_header }

    it "returns a table header" do
      expect(ticket_list_header).to include("| Status   |")
    end
  end

  describe "#ticket_list_uri" do
    let(:ticket_list_uri) { subject.ticket_list_uri(path) }

    context "when the path is valid" do
      let(:path) do
        "https://anar.zendesk.com/api/v2/tickets.json?page=3&per_page=25"
      end

      it "returns a valid path" do
        expect(ticket_list_uri.path).to eq(
          "/api/v2/tickets.json"
        )
      end

      it "returns valid queries" do
        expect(ticket_list_uri.query).to eq(
          "page=3&per_page=25"
        )
      end
    end
  end
end
