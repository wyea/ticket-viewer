require "spec_helper"
require "ticket_commander"

RSpec.describe TicketCommander do
  let(:ticket_commander) { TicketCommander.new }

  describe "#enter_command" do
    let(:enter_command) { ticket_commander.enter_command(command) }

    context "when command is invalid" do
      let(:command) { "A53" }

      it "returns a command is invalid message" do
        expect(enter_command).to eq("Invalid command: 'A53'")
      end
    end
  end

  describe "#validate_command" do
    let(:validate_command) { ticket_commander.validate_command(command) }

    context "when outside the multipage mode" do
      context "when command is valid" do
        context "when command is to print all tickets" do
          let(:command) { "A" }

          it "returns 0" do
            ticket_commander.instance_variable_set(:@multipage_mode, false)
            expect(validate_command).to eq(0)
          end
        end

        context "when command is to print a ticket #" do
          let(:command) { "T 53" }

          it "returns 0" do
            ticket_commander.instance_variable_set(:@multipage_mode, false)
            expect(validate_command).to eq(0)
          end
        end

        context "when command is invalid" do
          context "when the command is 'N'" do
            let(:command) { "N" }

            it "returns nil" do
              expect(validate_command).to be_nil
            end
          end

          context "when the command is 'P'" do
            let(:command) { "P" }

            it "returns nil" do
              expect(validate_command).to be_nil
            end
          end

          context "when the command is M" do
            let(:command) { "M" }

            it "returns nil" do
              expect(validate_command).to be_nil
            end
          end
        end
      end
    end

    context "when inside the multipage mode" do
      context "when command is valid" do
        context "when command is 'N' - next page" do
          let(:command) { "N" }

          it "returns 0" do
            ticket_commander.instance_variable_set(:@multipage_mode, true)
            expect(validate_command).to eq(0)
          end
        end

        context "when command is 'P' - previous page" do
          let(:command) { "P" }

          it "returns 0" do
            ticket_commander.instance_variable_set(:@multipage_mode, true)
            expect(validate_command).to eq(0)
          end
        end

        context "when command is 'M' - previous page" do
          let(:command) { "M" }

          it "returns 0" do
            ticket_commander.instance_variable_set(:@multipage_mode, true)
            expect(validate_command).to eq(0)
          end
        end
      end

      context "when command is invalid" do
        context "when the command is 'A' - all tickets" do
          let(:command) { "A" }

          it "returns nil" do
            ticket_commander.instance_variable_set(:@multipage_mode, true)
            expect(validate_command).to be_nil
          end
        end

        context "when there command is 'T 53' - ticket 53" do
          let(:command) { "T 53" }

          it "returns nil" do
            ticket_commander.instance_variable_set(:@multipage_mode, true)
            expect(validate_command).to be_nil
          end
        end

        context "when there command is 'A 53' - always invalid" do
          let(:command) { "A 53" }

          it "returns nil" do
            ticket_commander.instance_variable_set(:@multipage_mode, true)
            expect(validate_command).to be_nil
          end
        end
      end
    end

    context "when command is invalid" do
      context "when there is a digit after A" do
        let(:command) { "A 53" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end

      context "when there is no ticket number after T" do
        let(:command) { "T" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end

      context "when there is no space between T and a ticket number" do
        let(:command) { "T53" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end

      context "when the ticket number is 0" do
        let(:command) { "T 0" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end

      context "when there is no T before a ticket number" do
        let(:command) { "53" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end

      context "when a ticket number goes before T" do
        let(:command) { "53 T" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end

      context "when the command is just a random conbination" do
        let(:command) { "Za65" }

        it "returns nil" do
          expect(validate_command).to be_nil
        end
      end
    end
  end

  describe "#execute_command" do
    let(:execute_command) { ticket_commander.execute_command(command) }

    context "when command is 'A' - calling a list of tickets" do
      let(:command) { "A" }

      it "returns a list of tickets that includes the following text" do
        expect(execute_command).to include(
          "1 | open     | Tue, 05 Jun 2018 12:42:08 GMT "\
          "| Sample ticket: Meet the ticket"
        )
      end
    end

    context "ticket command is 'A', but authorization is unsuccessful" do
      let(:command) { "A" }

      it "returns a message saying that authorization wasn't successful" do
        cached_password = ENV["PASSWORD"]
        ENV["PASSWORD"] = "aaaaa"
        expect(execute_command).to eq(
          "Ask your parents if you can go into the basement..."\
          "They must give you the right password."
        )
        ENV["PASSWORD"] = cached_password
      end
    end

    context "when command is 'T 53' - calling an existing ticket" do
      let(:command) { "T 53" }

      it "returns a message that includes the ticket subject" do
        expect(execute_command).to include(
          "Subject:        reprehenderit id non aliqua enim\n"
        )
      end
    end

    context "when command is 'T 1153' - calling a non-existing ticket" do
      let(:command) { "T 1153" }

      it "returns a message saying that the record wasn't found" do
        expect(execute_command).to eq(
          "The record wasn't found... Most likely, it was deleted "\
          "or you are from the future where it already exists."
        )
      end
    end

    context "ticket command is valid, but authorization is unsuccessful" do
      let(:command) { "T 53" }

      it "returns a message saying that authorization wasn't successful" do
        cached_password = ENV["PASSWORD"]
        ENV["PASSWORD"] = "aaaaa"
        expect(execute_command).to eq(
          "Ask your parents if you can go into the basement..."\
          "They must give you the right password."
        )
        ENV["PASSWORD"] = cached_password
      end
    end
  end

  describe "#ticket_number" do
    let(:ticket_number) { ticket_commander.ticket_number(command) }

    context "when command is 'T 1'" do
      let(:command) { "T 1" }

      it "returns '1'" do
        expect(ticket_number).to eq("1")
      end
    end

    context "when command is 'T 53'" do
      let(:command) { "T 53" }

      it "returns '53'" do
        expect(ticket_number).to eq("53")
      end
    end
  end
end
