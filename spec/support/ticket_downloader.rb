require "spec_helper"
require "ticket_downloader"

shared_examples_for TicketDownloader do
  subject { described_class.new }

  describe "#fetch_info" do
    let(:fetch_info) { subject.fetch_info(uri) }

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
    let(:convert)  { subject.convert(response) }
    let(:response) { subject.fetch_info(uri) }

    context "when the response is valid json" do
      let(:uri) { URI("https://anar.zendesk.com/api/v2/tickets/53.json") }

      it "returns a hash" do
        expect(convert).to be_an_instance_of(Hash)
      end
    end
  end

  describe "#valid_json?" do
    let(:valid_json) { subject.valid_json?(json) }

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
    let(:parse_time) { subject.parse_time(time) }

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
    let(:valid_time) { subject.valid_time?(time) }

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
