# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  subject { described_class }

  permissions ".scope" do
    it "should equal the expected scope" do
      expect(UserPolicy::Scope.new(user, User).resolve).to eq(User.all)
    end
  end

  permissions :index? do
    context "for an admin" do
      it "can show a list" do
        expect(subject).to permit(admin)
      end
    end

    context "for a user" do
      it "cannot show a list to a regular user" do
        expect(subject).not_to permit(user)
      end
    end
  end

  permissions :edit? do
    context "for an admin" do
      it "can be edited" do
        expect(subject).to permit(admin)
      end
    end

    context "for a user" do
      it "cannot be edited" do
        expect(subject).not_to permit(user)
      end
    end
  end

  permissions :update? do
    context "for an admin" do
      it "can be updated" do
        expect(subject).to permit(admin)
      end
    end

    context "for a user" do
      it "cannot be updated" do
        expect(subject).not_to permit(user)
      end
    end
  end

  permissions :create? do
    context "for an admin" do
      it "cannot be created" do
        expect(subject).not_to permit(user)
      end
    end
    context "for a user" do
      it "cannot be created" do
        expect(subject).not_to permit(user)
      end
    end
  end
end
