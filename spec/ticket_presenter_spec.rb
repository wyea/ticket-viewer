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

      it "returns a hash with the ticket data" do
        expect(view_ticket).to eq(
          {"ticket"=>
           {"url"=>"https://anar.zendesk.com/api/v2/tickets/53.json",
            "id"=>53,
            "external_id"=>nil,
            "via"=>{"channel"=>"api",
                    "source"=>{"from"=>{}, "to"=>{}, "rel"=>nil}},
           "created_at"=>"2018-06-06T03:20:10Z",
           "updated_at"=>"2018-06-10T11:09:24Z",
           "type"=>nil,
           "subject"=>"reprehenderit id non aliqua enim",
           "raw_subject"=>"reprehenderit id non aliqua enim",
           "description"=>
           "Consequat ipsum deserunt eiusmod veniam id ex. Nulla "\
             "consectetur et sit voluptate. Id qui Lorem amet laborum "\
             "sunt aute reprehenderit minim fugiat deserunt deserunt "\
             "dolor sint. Consectetur voluptate elit esse eiusmod magna. "\
             "Exercitation nulla deserunt laborum dolor et voluptate fugiat "\
             "minim. Lorem Lorem ullamco id Lorem ea officia ad laborum "\
             "nulla consectetur.\n\n"\
             "Adipisicing esse aute eiusmod laboris aute aliquip. Laboris "\
             "irure eu velit exercitation qui ullamco veniam mollit esse "\
             "aliquip consequat. In id voluptate amet in sunt aliquip. "\
             "Nostrud consequat officia exercitation aliqua nostrud quis. "\
             "Reprehenderit amet sint do ex mollit nulla enim in in ea "\
             "elit Lorem.",
             "priority"=>nil,
             "status"=>"open",
             "recipient"=>nil,
             "requester_id"=>363050229293,
             "submitter_id"=>363050229293,
             "assignee_id"=>363050229293,
             "organization_id"=>360029891553,
             "group_id"=>360001068553,
             "collaborator_ids"=>[],
             "follower_ids"=>[],
             "email_cc_ids"=>[],
             "forum_topic_id"=>nil,
             "problem_id"=>nil,
             "has_incidents"=>false,
             "is_public"=>true,
             "due_at"=>nil,
             "tags"=>["culpa", "ex", "non"],
             "custom_fields"=>[],
             "satisfaction_rating"=>nil,
             "sharing_agreement_ids"=>[],
             "fields"=>[],
             "followup_ids"=>[],
             "brand_id"=>360000737293,
             "allow_channelback"=>false,
             "allow_attachments"=>true}}
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
end
