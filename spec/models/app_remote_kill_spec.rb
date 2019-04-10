require 'rails_helper'

RSpec.describe AppRemoteKill do
  it "is valid with valid args" do
    expect(FactoryBot.build(:app_remote_kill)).to be_valid
  end

  it "is invalid with an invalid variant" do
    subject = FactoryBot.build(:app_remote_kill, override_to: :nonexistant)

    expect(subject).to have(1).error_on(:override_to)
  end

  it "is valid with nil fixed_version" do
    subject = FactoryBot.build(:app_remote_kill, first_bad_version: "1.0", fixed_version: nil)

    expect(subject).to be_valid
  end

  it "is valid with a fixed_version greater than first_bad_version" do
    subject = FactoryBot.build(:app_remote_kill, first_bad_version: "1.0", fixed_version: "1.1")

    expect(subject).to be_valid
  end

  it "is invalid with a fixed_version less than first_bad_version" do
    subject = FactoryBot.build(:app_remote_kill, first_bad_version: "1.0", fixed_version: "0.9")

    expect(subject).to have(1).error_on(:fixed_version)
  end

  it "is invalid with a fixed_version equal to first_bad_version" do
    subject = FactoryBot.build(:app_remote_kill, first_bad_version: "1.0", fixed_version: "1.0")

    expect(subject).to have(1).error_on(:fixed_version)
  end

  context "with an existing open-ended remote kill" do
    let(:app) { FactoryBot.create(:app) }
    let(:split) { FactoryBot.create(:split) }
    let!(:existing_remote_kill) do
      FactoryBot.create(:app_remote_kill, app: app, split: split, first_bad_version: "1.0", fixed_version: nil)
    end

    it "is valid if it is fixed before the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: "0.9")

      expect(subject).to be_valid
    end

    it "is valid if it is fixed at the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: "1.0")

      expect(subject).to be_valid
    end

    it "is invalid if it is fixed after the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: "1.1")

      expect(subject).to have(1).error_on(:base)
    end

    it "is invalid if it is open-ended and starts before the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: nil)

      expect(subject).to have(1).error_on(:base)
    end

    it "is invalid if it is open-ended and starts after the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.1", fixed_version: nil)

      expect(subject).to have(1).error_on(:base)
    end

    it "is valid if it's for a different app" do
      subject = FactoryBot.build(:app_remote_kill, app: FactoryBot.create(:app), split: split, first_bad_version: "1.1", fixed_version: nil)

      expect(subject).to be_valid
    end

    it "is valid if it's for a different split" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: FactoryBot.create(:split), first_bad_version: "1.1", fixed_version: nil)

      expect(subject).to be_valid
    end
  end

  context "with an existing completed remote kill" do
    let(:app) { FactoryBot.create(:app) }
    let(:split) { FactoryBot.create(:split) }
    let!(:existing_remote_kill) do
      FactoryBot.create(:app_remote_kill, app: app, split: split, first_bad_version: "1.0", fixed_version: "1.2")
    end

    it "is valid if it is fixed before the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: "0.9")

      expect(subject).to be_valid
    end

    it "is valid if it is fixed at the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: "1.0")

      expect(subject).to be_valid
    end

    it "is invalid if it starts before and is fixed after the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: "1.1")

      expect(subject).to have(1).error_on(:base)
    end

    it "is invalid if it is open-ended and starts before the existing first_bad_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.8", fixed_version: nil)

      expect(subject).to have(1).error_on(:base)
    end

    it "is invalid if it is open-ended and starts before the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.1", fixed_version: nil)

      expect(subject).to have(1).error_on(:base)
    end

    it "is valid if it is open-ended and starts at the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.2", fixed_version: nil)

      expect(subject).to be_valid
    end

    it "is valid if it is open-ended and starts after the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.3", fixed_version: nil)

      expect(subject).to be_valid
    end

    it "is invalid if it starts before the existing first_bad_version and is fixed after the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "0.9", fixed_version: "1.3")

      expect(subject).to have(1).error_on(:base)
    end

    it "is invalid if it starts after the existing first_bad_version and is fixed before the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.1", fixed_version: "1.1.1")

      expect(subject).to have(1).error_on(:base)
    end

    it "is invalid if it starts after the existing first_bad_version and is fixed after the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.1", fixed_version: "1.3")

      expect(subject).to have(1).error_on(:base)
    end

    it "is valid if it starts at the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.2", fixed_version: "1.3")

      expect(subject).to be_valid
    end

    it "is valid if it starts after the existing fixed_version" do
      subject = FactoryBot.build(:app_remote_kill, app: app, split: split, first_bad_version: "1.3", fixed_version: "1.4")

      expect(subject).to be_valid
    end

    it "does not conflict with itself" do
      expect(existing_remote_kill).to be_valid
    end
  end

  describe ".affecting" do
    context "with an existing open-ended remote kill" do
      let(:app) { FactoryBot.create(:app) }
      let(:split) { FactoryBot.create(:split) }
      let!(:existing_remote_kill) do
        FactoryBot.create(:app_remote_kill, app: app, split: split, first_bad_version: "1.0", fixed_version: nil)
      end

      it "returns remote_kills starting before app version" do
        app_build = app.define_build(version: "1.1", built_at: nil)

        expect(described_class.affecting(app_build)).to include(existing_remote_kill)
      end

      it "returns remote_kills starting on app version" do
        app_build = app.define_build(version: "1.0", built_at: nil)

        expect(described_class.affecting(app_build)).to include(existing_remote_kill)
      end

      it "doesn't return remote kills starting after app version" do
        app_build = app.define_build(version: "0.9", built_at: nil)

        expect(described_class.affecting(app_build)).not_to include(existing_remote_kill)
      end

      it "doesn't return remote kills for the wrong app" do
        app_build = FactoryBot.create(:app).define_build(version: "1.1", built_at: nil)

        expect(described_class.affecting(app_build)).not_to include(existing_remote_kill)
      end
    end

    context "with an existing completed remote kill" do
      let(:app) { FactoryBot.create(:app) }
      let(:split) { FactoryBot.create(:split) }
      let!(:existing_remote_kill) do
        FactoryBot.create(:app_remote_kill, app: app, split: split, first_bad_version: "1.0", fixed_version: "1.2")
      end

      it "doesn't return remote kills ending before app version" do
        app_build = app.define_build(version: "1.3", built_at: nil)

        expect(described_class.affecting(app_build)).not_to include(existing_remote_kill)
      end

      it "doesn't return remote kills fixed on app version" do
        app_build = app.define_build(version: "1.2", built_at: nil)

        expect(described_class.affecting(app_build)).not_to include(existing_remote_kill)
      end

      it "returns remote_kills starting before app version and fixed after app_version" do
        app_build = app.define_build(version: "1.1", built_at: nil)

        expect(described_class.affecting(app_build)).to include(existing_remote_kill)
      end

      it "returns remote_kills starting on app version" do
        app_build = app.define_build(version: "1.0", built_at: nil)

        expect(described_class.affecting(app_build)).to include(existing_remote_kill)
      end

      it "doesn't return remote_kills starting after app version" do
        app_build = app.define_build(version: "0.9", built_at: nil)

        expect(described_class.affecting(app_build)).not_to include(existing_remote_kill)
      end
    end
  end
end
