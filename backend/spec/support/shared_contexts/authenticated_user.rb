RSpec.shared_context "authenticated user" do
  let(:current_user) { create(:user) }
  let(:auth_headers) { auth_headers_for(current_user) }
end

RSpec.shared_context "authenticated owner" do
  let(:owner) { create(:user) }
  let(:auth_headers) { auth_headers_for(owner) }
end
