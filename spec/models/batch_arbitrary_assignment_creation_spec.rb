require 'rails_helper'

RSpec.describe BatchArbitraryAssignmentCreation do
  subject { BatchArbitraryAssignmentCreation.new params }

  let(:visitor_id) { SecureRandom.uuid }

  let(:params) do
    {
      visitor_id: visitor_id,
      assignments: [
        {
          split_name: "split",
          variant: "variant1",
          context: "the_context"
        },
        {
          split_name: "split2",
          variant: "variant2",
          context: "the_context"
        }
      ]
    }
  end

  before do
    allow(ActiveRecord::Base).to receive(:transaction).and_call_original
    allow(ArbitraryAssignmentCreation).to receive(:create!)
  end

  describe "#save!" do
    it "creates ArbitraryAssignmentCreation for each assignment within a transaction" do
      subject.save!

      expect(ActiveRecord::Base).to have_received(:transaction)

      expect(ArbitraryAssignmentCreation).to have_received(:create!).with(
        hash_including(
          visitor_id: visitor_id,
          split_name: "split",
          variant: "variant1",
          context: "the_context"
        )
      )

      expect(ArbitraryAssignmentCreation).to have_received(:create!).with(
        hash_including(
          visitor_id: visitor_id,
          split_name: "split2",
          variant: "variant2",
          context: "the_context"
        )
      )
    end

    it "always specifies mixpanel_result as success" do
      subject.save!

      expect(ArbitraryAssignmentCreation).to have_received(:create!).with(
        hash_including(
          mixpanel_result: "success"
        )
      ).twice
    end

    context "with force option" do
      let(:params) do
        {
          visitor_id: visitor_id,
          assignments: [
            {
              split_name: "split",
              variant: "variant1",
              context: "the_context"
            },
            {
              split_name: "split2",
              variant: "variant2",
              context: "the_context"
            }
          ],
          force: true
        }
      end

      it "passes the option through to the underlying ArbitraryAssignmentCreation" do
        subject.save!

        expect(ArbitraryAssignmentCreation).to have_received(:create!).with(
          hash_including(
            force: true
          )
        ).twice
      end
    end
  end

  describe ".create!" do
    it "returns the created instance" do
      batch_assignment_creation = BatchArbitraryAssignmentCreation.create! params
      expect(batch_assignment_creation).to be_a(BatchArbitraryAssignmentCreation)
    end
  end
end
