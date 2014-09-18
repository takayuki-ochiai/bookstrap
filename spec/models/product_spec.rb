require 'spec_helper'

describe Product do
  let(:product){ create(:product) }
  let(:second_user){ create(:user) }
  let(:user){ create(:user) }
  subject{ product }

  describe "property test" do
    it { should respond_to(:id) }
    it { should respond_to(:title)}
    it { should respond_to(:genre)}
    it { should respond_to(:link)}
    it { should respond_to(:microposts)}
    it { should respond_to(:users)}
    it { should be_valid }
  end

  describe "validation" do
    context "invalid url is input" do
      before { product.link = "Example" }
      it { should_not be_valid }
    end

    context "invalid title is input" do
      before { product.title = " "}
      it { should_not be_valid}
    end

    context "invalid genre is input" do
      before { product.genre = " "}
      it { should_not be_valid }
    end
  end

  describe " rerationships of micropost model " do
    let!(:older_micropost) do
      create(:micropost, content: "test", user_id: user.id, product_id: product.id, created_at: 1.day.ago)
    end
    let!(:newer_micropost) do
      create(:micropost, content: "test", user_id: second_user.id, product_id: product.id, created_at: 1.hour.ago)
    end

    it "is deleted when product is deleted" do
      microposts = product.microposts.to_a
      product.destroy
      expect(microposts).not_to be_empty
      microposts.each do |micropost|
        expect(Micropost.where(id: micropost.id)).to be_empty
      end
    end
  end
end
