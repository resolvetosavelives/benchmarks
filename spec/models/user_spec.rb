require "rails_helper"

RSpec.describe User, type: :model do
  let(:sub_claim) { "pt1kkA32DNtJvopToI88YPH1U7QiBFZhA9aMJgXxxjI" }

  describe ".new with azure_identity" do
    before { Rails.application.config.azure_auth_enabled = true }
    after { Rails.application.config.azure_auth_enabled = false }

    it "creates without error" do
      user = User.where(azure_identity: sub_claim).first_or_initialize
      user.name = "name"
      expect(user).to be_azure_authenticated

      expect { user.save! }.to change { User.count }.by(1)
      expect(user.azure_identity).to eq(sub_claim)
      expect(user.name).to eq("name")
    end

    it "creates with no name" do
      user = User.where(azure_identity: sub_claim).first_or_initialize

      expect { user.save! }.to change { User.count }.by(1)
      expect(user.azure_identity).to eq(sub_claim)
      expect(user.name).to be_nil
    end

    it "enforces unique azure_identity, but not unique (blank) email" do
      User.create!(azure_identity: sub_claim)
      User.create!(azure_identity: sub_claim + "2")
      expect { User.create!(azure_identity: sub_claim) }.to raise_error(
        ActiveRecord::RecordInvalid
      )
    end
  end

  describe "#azure_authenticated?" do
    context "with azure auth enabled" do
      before { Rails.application.config.azure_auth_enabled = true }
      after { Rails.application.config.azure_auth_enabled = false }

      let(:user) { user = create(:user, azure_identity: sub_claim) }

      it "is false when azure_auth_enabled is false" do
        user = User.where(azure_identity: sub_claim).first_or_initialize
        expect(user).to be_azure_authenticated
      end
    end
  end
end
