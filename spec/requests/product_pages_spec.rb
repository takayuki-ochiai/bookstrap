require 'spec_helper'

describe "作品CRUDページ" do
  subject { page }
  let(:user) { create(:user) }
  let(:error) { "エラー" }
  before do 
    sign_in user
    visit root_path 
  end

  describe "visit create_micropost" do
    before { visit create_micropost_product_path(create(:product)) }

    it { should have_title "感想を投稿"}

      describe "render error message " do
        before {click_button "投稿する"}
        it { should have_content('error') }
      end


    context "create valid micropost" do
      before { fill_in "投稿内容", with: "testest"}
      it "is valid micropost content" do
        expect { click_button "投稿する" }.to change(Micropost, :count)
      end
    end
  end

  describe "genre link" do
    it { should have_link "文学" }
    it { should have_link "恋愛" }
    it { should have_link "歴史" }
    it { should have_link "推理" }
    it { should have_link "ファンタジー" }
    it { should have_link "SF" }
    it { should have_link "ホラー" }
    it { should have_link "コメディ" }
    it { should have_link "冒険" }
    it { should have_link "学園" }
    it { should have_link "戦記" }
    it { should have_link "童話" }
    it { should have_link "詩" }
    it { should have_link "エッセイ" }
    it { should have_link "リプレイ" }
    it { should have_link "その他" }

    context "click genre link" do
      before(:all) { 80.times { create(:product) } }
      after(:all) { Product.delete_all }

      context "click literature link" do
        before { click_link "文学" }
        it { should have_selector("ul.products li", text: "文学" ) }
        it { should_not have_selector("ul.products li", text: "恋愛") }
      end

      context "click love link" do
        before { click_link "恋愛" }
        it { should have_selector("ul.products li", text: "恋愛")}
        it { should_not have_selector("ul.products li", text: "文学") }
      end

    end
  end



  describe "new product page" do
    let(:submit) { "投稿する" }
    before { click_link "新しい作品の追加" }

    it { should have_title("新規作品登録") }
    it { should have_content("その他")}

    describe "invalid product" do
      it "is invalid with no data" do
        expect { click_button submit }.not_to change(Product, :count)
      end
    end

    describe "render error message" do
      before { click_button submit }
      it { should have_content(error) }
    end

    context "guest user" do
      before { sign_out }
      it { should_not have_title(user.nickname) }
      it { should_not have_link('新しい作品の追加', href: new_product_path)}
    end

    context "valid product" do
      before do
        fill_in "作品名",         with: "やる夫の額には選定印が輝くようです"
        select("文学", :from => "product_genre")
        fill_in "リンク",           with: "http://yarutra.blog72.fc2.com/blog-entry-3344.html"
      end

      it "is valid to create product" do
        expect { click_button submit }.to change(Product, :count).by(1)
      end
    end
  end

  describe "visit show product" do
    let(:product) { create(:product) }
    before(:each) {visit product_path(product) }
    it { should have_title(product.title) }
    it { should have_content(product.title) }
  end

  describe "visit index product" do
    before { visit products_path }
    it { should have_title('登録作品の一覧') }
    describe "pagenation" do
      before(:all) { 60.times { create(:product) } }
      after(:all) { Product.delete_all }
      #ページネーションタグが作られているか?
      it { should have_selector("ul.pagination") }

      it "render product pagenation" do
        Product.paginate(page: 1).each do |product|
          expect(page).to have_selector('li', text: product.title)
        end
      end

      describe "search function" do
        let(:select_genre){ "文学" }
        let(:free_word){ "小説" }
        let(:search){ "検索" }
        let(:missmatch_word){ "テスト" }
        let(:missmatch_genre){ "恋愛" }

        context "search field is used" do
          context "title search" do
            before do 
              fill_in "（例）  羅生門 タイトル or ジャンル", with: free_word
              click_button search
            end
            it { should have_selector("ul.products li", text: free_word) }
            it { should_not have_selector("ul.products li", text: missmatch_word ) }
          end

          context "genre search" do
            before do 
              fill_in "（例）  羅生門 タイトル or ジャンル", with: select_genre
              click_button search
            end

            it { should have_selector("ul.products li", text: select_genre) }
            it { should_not have_selector("ul.products li", text: missmatch_genre) }
          end

          context "visit search_product page" do
            before { visit search_product_products_path}
            it { should have_title("感想を投稿（作品を探す）")}
          end
        end
      end
    end
  end



  describe "visit update and delete products" do
    before(:all) {60.times { create(:product) } }
    after(:all) { Product.delete_all }
    before { visit products_path }
    it { should_not have_link("delete") }
    it { should_not have_link("edit")}

    context "signin admin user" do
      let(:admin) { FactoryGirl.create(:admin) }
      before do
        sign_in admin 
        visit products_path
      end

      it { should have_link('delete', href: product_path(Product.first)) }
      it { should have_link('edit', href: edit_product_path(Product.first)) }
      it "should be able to delete product" do
        expect do
           click_link('delete', match: :first)
        end.to change(Product, :count).by(-1)
      end

      describe "edit product page" do
        let(:product){ Product.first }
        before { visit edit_product_path(Product.first) }
        it { should have_content("作品名") }
        it { should have_title("Edit") }

        context "valid product" do
          let(:new_title){ "testtesttest" }
          let(:new_genre){ "文学" }
          let(:new_link){ "http://link.ameba.jp/225923/" }
          before do
            fill_in "作品名", with: new_title
            select(new_genre, :from => "product_genre")
            fill_in "リンク", with: new_link
            click_button "編集する"
          end

          it { should have_title("登録作品の一覧") }
          it { should have_selector("div.alert.alert-success")}
          specify { expect(product.reload.title).to  eq new_title }
          specify { expect(product.reload.genre).to eq new_genre }
          specify { expect(product.reload.link).to eq new_link }
        end

        context "invalid product" do
          let(:new_genre){ "文学" }
          before do 
            fill_in "作品名", with: " "
            select(new_genre, :from => "product_genre")
            fill_in "リンク", with: " "
            click_button "編集する"
          end

          it{ should have_content(error)}
        end
      end
    end
  end
end