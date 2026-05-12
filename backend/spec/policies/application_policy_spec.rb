require "rails_helper"

RSpec.describe ApplicationPolicy do
  let(:user)   { build_stubbed(:user) }
  let(:record) { double("record") }

  subject(:policy) { described_class.new(user, record) }

  it "expõe user e record" do
    expect(policy.user).to eq(user)
    expect(policy.record).to eq(record)
  end

  describe "ações padrão" do
    it "nega index?"   do expect(policy.index?).to   be false end
    it "nega show?"    do expect(policy.show?).to    be false end
    it "nega create?"  do expect(policy.create?).to  be false end
    it "nega update?"  do expect(policy.update?).to  be false end
    it "nega destroy?" do expect(policy.destroy?).to be false end
  end

  describe ApplicationPolicy::Scope do
    subject(:scope) { described_class.new(user, User.all) }

    it "exige que subclasses implementem #resolve" do
      expect { scope.resolve }.to raise_error(NotImplementedError, /resolve/)
    end
  end
end
