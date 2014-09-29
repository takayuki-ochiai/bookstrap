require 'spec_helper'

describe ProductsController do
  describe "user access" do
    let(:common_user){ create(:user) }
    let(:product){ create(:product) }
    before { sign_in common_user, no_capybara: true }

    describe "GET#create_micropost" do
      #@productに要求された連絡先を割り当てること
      it "assigns the requested product to @product" do
        get :create_micropost, id: product
        expect(assigns(:product)).to eq product
      end
      #@micropostに新しい連絡先を割り当てること
      it "assigns a new Micropost to @micropost" do
        get :create_micrpost, id: product
        expect(assigns(:micropost)).to be_a_new(Micropost)
      end
      #:create_micropostテンプレートを表示すること
      it "renders the :show template" do
        get :create_micorpost, id: product
        expect(response).to render_template :create_micropost
      end
    end
  end
end
