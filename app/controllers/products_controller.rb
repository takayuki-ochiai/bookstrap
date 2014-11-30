class ProductsController < ApplicationController
  before_action :signed_in_user, only: [:new, :create, :edit, :update, :destroy, :create_micropost]
  before_action :admin_user,     only: [:destroy, :edit, :update]
  before_action :set_product,    only: [:show, :edit, :update, :create_micropost]

  #ransackを使って作品を検索した後、ページネーションを使用
  def index
    @search = Product.search(params[:q])#search_formから値を取得
    @products = @search.result.paginate(page: params[:page])
  end

  def search_product
    @search = Product.search(params[:q])#search_formから値を取得
    @products = @search.result.paginate(page: params[:page])
  end


  def show
    @keyword = @product.title
    Amazon::Ecs.debug = true
    if @keyword.present?
      @res = Amazon::Ecs.item_search(@keyword, :search_index => 'Books', :response_group => 'Medium')
      render layout: "no_side"
    else
      return
      render layout: "no_side"
    end
  end

  def new
    @product = Product.new
  end

  def create
    @product=Product.new(product_params)
    if @product.save
      flash[:success] = "作品の登録に成功しました！"
      redirect_to create_micropost_product_path(@product.id)
    else
      render "new"
    end
  end

  def edit
  end

  def update
    if @product.update_attributes(product_params)
      flash[:success] = "Product updated"
      redirect_to products_url
    else
      render "edit"
    end
  end

  def destroy
    Product.find(params[:id]).destroy
    flash[:success] = "Product destroyed."
    redirect_to products_url
  end

  #マイクロポスト投稿ページ
  def create_micropost
    @micropost = current_user.microposts.build if signed_in?
  end

  #ジャンル別で表示する機能
  # TODO :ジャンル別表示のMVCがなんか冗長だからうまいやりかたを考えること
  def literature
    genre_search("文学")
  end

  def love
    genre_search("恋愛")
  end

  def history
    genre_search("歴史")
  end

  def mystery
    genre_search("推理")
  end

  def fantasy
    genre_search("ファンタジー")
  end

  def sf
    genre_search("SF")
  end

  def horror
    genre_search("ホラー")
  end

  def comedy
    genre_search("コメディ")
  end

  def adventure
    genre_search("冒険")
  end

  def academy
    genre_search("学園")
  end

  def millitary
    genre_search("戦記")
  end

  def fairy_tail
    genre_search("童話")
  end

  def poem
    genre_search("詩")
  end

  def essay
    genre_search("エッセイ")
  end

  def replay
    genre_search("リプレイ")
  end

  def others
    genre_search("その他")
  end

  private
    def set_product
      @product = Product.find(params[:id])
      @microposts = @product.microposts.paginate(page: params[:page], :per_page => 10)
    end

    def product_params
      params.require(:product).permit(:id, :title, :genre, :link)
    end

    def genre_search(genre)
      @search = Product.search(:genre_cont => genre)
      @products = @search.result.paginate(page: params[:page])
    end
end
