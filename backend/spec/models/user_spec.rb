require "rails_helper"

RSpec.describe User, type: :model do
  describe "validações" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
  end

  describe "módulos Devise" do
    it "inclui jwt_authenticatable" do
      expect(User.devise_modules).to include(:jwt_authenticatable)
    end

    it "inclui confirmable" do
      expect(User.devise_modules).to include(:confirmable)
    end

    it "inclui lockable" do
      expect(User.devise_modules).to include(:lockable)
    end
  end

  describe "factory" do
    it "cria usuário válido confirmado" do
      expect(build(:user)).to be_valid
    end

    it "cria usuário não confirmado com trait :unconfirmed" do
      user = build(:user, :unconfirmed)
      expect(user.confirmed_at).to be_nil
    end

    it "cria usuário bloqueado com trait :locked" do
      user = build(:user, :locked)
      expect(user.locked_at).to be_present
    end
  end
end
