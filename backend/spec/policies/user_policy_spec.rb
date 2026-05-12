require "rails_helper"

RSpec.describe UserPolicy do
  let(:user)  { build_stubbed(:user) }
  let(:outro) { build_stubbed(:user) }

  describe "#show?" do
    it "permite quando o registro é o próprio usuário" do
      expect(described_class.new(user, user).show?).to be true
    end

    it "nega quando o registro é outro usuário" do
      expect(described_class.new(user, outro).show?).to be false
    end
  end

  describe "#update?" do
    it "permite quando o registro é o próprio usuário" do
      expect(described_class.new(user, user).update?).to be true
    end

    it "nega quando o registro é outro usuário" do
      expect(described_class.new(user, outro).update?).to be false
    end
  end
end
