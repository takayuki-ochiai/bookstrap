require 'spec_helper'

describe Micropost do

  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:micropost) { user.microposts.build(content: "test", product_id: product.id) }

  subject { micropost }
  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:add_evaluation) }

  it { should be_valid }
  its(:user){ should eq user }#マイクロポストモデルがuserモデルと結合しているか
  its(:product){ should eq product } #マイクロポストモデルがproductモデルと結合しているか

  context "without user_id is invalid" do
    before { micropost.user_id = nil }
    it { should_not be_valid }
  end

  context "no content is invalid" do
    before { micropost.content = " " }
    it { should_not be_valid }
  end

  context "contents with more than 400 letters is invalid" do
    before { micropost.content = "a" * 401 }
    it { should_not be_valid }
  end
end