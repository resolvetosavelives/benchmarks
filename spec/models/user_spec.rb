require "rails_helper"

RSpec.describe User, type: :model do
  describe "#admin?" do
    it "returns false for a new record" do
      expect(User.new.admin?).to eq(false)
    end

    it "returns true for an admin record" do
      user = User.new(role: "Admin").admin?
      expect(user).to eq(true)
    end

    it "returns true for an admin record case insensitive" do
      user = User.new(role: "aDmIn").admin?
      expect(user).to eq(true)
    end
  end

  describe "#admin!" do
    context "when user is an admin" do
      let(:user) { create(:user, role: "admin") }

      it "keeps admin role" do
        user.admin!
        expect(user.role).to eq("admin")
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user, role: "user") }

      it "sets role to admin" do
        user.admin!
        expect(user.role).to eq("admin")
      end
    end
  end

  describe "#remove_admin!" do
    context "when user is an admin" do
      let(:user) { create(:user, role: "admin") }

      it "sets role to user" do
        user.remove_admin!
        expect(user.role).to eq("user")
      end
    end

    context "when user is not an admin" do
      let(:user) { create(:user, role: "user") }

      it "keeps existing role" do
        user.remove_admin!
        expect(user.role).to eq("user")
      end
    end
  end

  describe ".new with azure_identity" do
    before { Rails.application.config.azure_auth_enabled = true }
    after { Rails.application.config.azure_auth_enabled = false }
    let(:user_attrs) { attributes_for(:user) }
    let(:sub_claim) { "pt1kkA32DNtJvopToI88YPH1U7QiBFZhA9aMJgXxxjI" }

    it "creates without error" do
      user = User.where(azure_identity: sub_claim).first_or_initialize
      user.attributes = user_attrs
      expect(user).to be_azure_authenticated

      expect { user.save! }.to change { User.count }.by(1)
      expect(user.azure_identity).to eq(sub_claim)
      expect(user.email).to eq(user_attrs[:email])
    end
  end

  describe "#azure_authenticated?" do
    let(:sub_claim) { "pt1kkA32DNtJvopToI88YPH1U7QiBFZhA9aMJgXxxjI" }

    context "azure_auth_enabled is true" do
      before { Rails.application.config.azure_auth_enabled = true }
      after { Rails.application.config.azure_auth_enabled = false }

      context "and azure_identity is present" do
        let!(:user) { create(:user, azure_identity: sub_claim) }

        it "returns true" do
          expect(user.azure_authenticated?).to eq(true)
        end
      end

      context "and azure_identity is blank" do
        let!(:user) { create(:user, azure_identity: "") }

        it "returns false" do
          expect(user.azure_authenticated?).to eq(false)
        end
      end
    end

    context "azure_auth_enabled is false" do
      before { Rails.application.config.azure_auth_enabled = false }
      after { Rails.application.config.azure_auth_enabled = false }

      context "and azure_identity is present" do
        let!(:user) { create(:user, azure_identity: sub_claim) }

        it "returns false" do
          expect(user.azure_authenticated?).to eq(false)
        end
      end

      context "and azure_identity is blank" do
        let!(:user) { create(:user, azure_identity: nil) }

        it "returns false" do
          expect(user.azure_authenticated?).to eq(false)
        end
      end
    end
  end

  describe "validation" do
    describe "role" do
      let(:user) { build(:user, role: "asd") }

      it "valid? returns false and has a validation error on role" do
        expect(user).not_to be_valid
        expect(user.errors).to include(:role)
      end
    end

    describe "status" do
      let(:user) { build(:user, status: "asd") }

      it "valid? returns false and has a validation error on status" do
        expect(user).not_to be_valid
        expect(user.errors).to include(:status)
      end
    end

    describe "email" do
      let(:email) { "abc123@example.com" }
      before { create(:user, email: email) }

      it "must be unique" do
        user2 = build(:user, email: email)
        expect(user2).not_to be_valid
        expect(user2.errors).to include(:email)
      end
    end

    describe "azure_identity" do
      let(:sub_claim) { "pt1kkA32DNtJvopToI88YPH1U7QiBFZhA9aMJgXxxjI" }
      before { create(:user, azure_identity: sub_claim) }

      it "must be unique" do
        user2 = build(:user, azure_identity: sub_claim)
        expect(user2).not_to be_valid
        expect(user2.errors).to include(:azure_identity)
      end
    end
  end

  describe "#set_defaults" do
    context "when blank" do
      let(:user) { User.new }

      it "should have the default role" do
        expect(user.role).to eq(User::ROLES.first)
      end

      it "should have the default status" do
        expect(user.status).to eq(User::STATUSES.first)
      end
    end

    context "with pre-existing values" do
      let(:user) do
        User.new(role: User::ROLES.last, status: User::STATUSES.last)
      end

      it "should have the non-default role" do
        expect(user.role).to eq(User::ROLES.last)
      end

      it "should have the non-default status" do
        expect(user.status).to eq(User::STATUSES.last)
      end
    end
  end
end
