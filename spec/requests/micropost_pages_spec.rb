require 'spec_helper'

describe "micropost_pages" do
  subject { page }
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:product) { create(:product) }
  let(:product2) { create(:product) }
  let(:product3) { create(:product) }
  let(:error) { "エラー" }

  #userが２つの投稿を行った状態でTOPに遷移
  before do
    user.microposts.create(content: "test", product_id: product.id)
    user.microposts.create(content: "test", product_id: product2.id)
    other_user.follow!(user)
    other_user.microposts.create(content: "test", product_id: product.id)
    other_user.microposts.create(content: "test", product_id: product2.id)
    sign_in user
    visit root_path
  end

  #マイクロポストが表示される
  it "should render micropost feed" do
    user.feed.each do |item|
      expect(page).to have_selector("li##{item.id}", text: item.content)
    end
  end
  
  context "edit micropost" do
    #micropost = create(:micropost, user_id: user, product_id: product)
    before { visit edit_micropost_path(user.microposts.first) }
    it { should have_title("感想を編集する")}
    context "update invalid micropost" do
      before do
        fill_in "投稿内容", with: " "
        click_button "編集する"
      end
      it{ should have_content(error)}
    end
    

    context "edit valid micropost" do
      let(:new_content){ "test2" }
      let(:old_content){ "test" }
      before do
        fill_in "投稿内容", with: new_content
        click_button "編集する"
      end
      specify { expect(user.microposts.first.reload.content).to     eq new_content }
      specify { expect(user.microposts.first.reload.content).not_to eq old_content }
    end
  end

  #TODO: activerecord reputationで適用できるテストの作成
  describe "good toggle buttons " do
    context "visit root path" do
      #TODO: 同じ人が二回以上マイクロポストにいいねができないようなテスト
      #TODO:特定のマイクロポストを選択して、いいねボタンを押す。
      #TODO:指定したマイクロポスト以外のいいねが増えていないことを確認する。
      it { should have_button "いいね！" }
      #いいねボタンが表示されるマイクロポストの中でも一番上のものを押す。
      it "should increment the good count" do
        expect do
          first(".likes_form").click_button "いいね！"
        end.to change(ReputationSystem::Evaluation, :count).by(1)
      end

      describe "toggling the button" do
        before { first(".likes_form").click_button "いいね！" }
        it { should have_xpath("//button", text:"いいね！を削除") }
      end
    end

    context "cancel good for the micropost" do
      #すでにいいねをした状態である
      before do
        other_user.microposts.first.add_evaluation(:likes, 1, user)
        visit root_path
      end
      it "should decrement the good count" do
        expect do
          first(".likes_form").click_button "いいね！を削除"
        end.to change(ReputationSystem::Evaluation, :count).by(-1)
      end

      describe "toggling the button" do
        before{ click_button "いいね！を削除" }
        it { should have_xpath("//button", text:"いいね！")}
      end
    end
  end

  describe "no signin user cannnot operate good button" do
    before { sign_out }
    describe "not signin user cannnot push good button" do
      describe "good_toggle buttons" do

        it { should_not have_button("いいね！")}
        pending "現在非ログイン中はいいねボタンを表示していないため保留" do
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
    end

    describe "not signin user cannot require good action create" do
      #TODO:  deleteメソッドが受理されないテストがNorouteMatch
      describe "require signin for no signin user create good action" do
        before { post likes_micropost_path(1) }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe "require signin for no signin user destroy good action" do
        before do
          other_user.microposts.first.add_evaluation(:likes, 1, user)
          post likes_micropost_path(1) 
        end
        specify { expect(response).to redirect_to(signin_path) }
      end
    end
  end
end


