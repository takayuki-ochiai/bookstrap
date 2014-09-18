require 'spec_helper'

describe "micropost_pages" do
  subject { page }
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:micropost){ create(:micropost) }
  before do
    sign_in user
    visit root_path
    10.times { create(:micropost) }
  end

  it "should render micropost feed" do
    user.feed.each do |item|
      expect(page).to have_selector("li##{item.id}", text: item.content)
    end
  end

  context "post Micropost" do
    before { visit product_path(product)}
    it { should have_title("#{product.title}")}
    it { should have_content("投稿内容")}

    describe "validation of micropost from product_view_page" do
      context "micropost is invalid" do
        it "is invalid without content " do
          expect { click_button "投稿する" }.not_to change(Micropost, :count)
        end
      end

      describe "render error message " do
        before {click_button "投稿する"}
        it { should have_content('error') }
      end

      describe"micropost is valid" do
        before { fill_in "レビュー投稿", with: "イケてるエンジニアになるぞー！"}
        it "is valid micropost content" do
          expect { click_button "投稿する" }.to change(Micropost, :count)
        end
      end
    end
  end

  #TODO: activerecord reputationで適用できるテストの作成
  describe "good toggle buttons " do
    context "visit root path" do
      #TODO: 同じ人が二回以上マイクロポストにいいねができないようなテスト
      let(:other_user) { create(:user) }
      before do
        other_user.follow!(user)
        create(:micropost, user: other_user)
        visit root_path
        sign_in user
      end

      it { should have_button "いいね！" }
      it "should increment the good count" do
        expect do
          click_button "いいね！"
        end.to change(ReputationSystem::Evaluation, :count).by(1)
      end

      describe "toggling the button" do
        before { click_button "いいね！" }
        it { should have_xpath("//input[@value='down']") }
      end
    end

    context "cancel good for the micropost" do
      #すでにいいねをした状態である
      before { click_button "いいね！" }
      it "should decrement the good count" do
        expect do
          click_button "いいね！を取り消す"
        end.to change(ReputationSystem::Evaluation, :count).by(-1)
      end

      describe "toggling the button" do
        before{ click_button "いいね！を取り消す" }
        it { should have_xpath("//input[@value='up']")}
      end
    end
  end

  describe "no signin user cannnot operate good button" do
    before { sign_out }

    describe "not signin user cannnot push good button" do
      describe "good_toggle buttons" do
        it "should not increment the good count" do
          expect do
            click_button "いいね！"
          end.not_to change(ReputationSystem::Evaluation, :count)
        end

        describe " require signin " do
          # OPTIMIZE: いいねボタンを押すと登録画面への誘導が示されるほうがよいかもしれない
          before { click_button "いいね！" }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end

    describe "not signin user cannot require good action create" do
      #TODO:  deleteメソッドが受理されないテストがNorouteMatch
      describe "require signin for no signin user create good action" do
        before { post likes_micropost_path(1) }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe "require signin for no signin user destroy good action" do
        before do
          micropost.add_evaluation(:likes, 1, user)
          post likes_micropost_path(1) 
        end
        specify { expect(response).to redirect_to(signin_path) }
      end
    end
  end
end


