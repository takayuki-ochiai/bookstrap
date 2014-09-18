class ProductsController < ApplicationController

  before_action :signed_in_user, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :admin_user, only: [:destroy, :edit, :update]
  before_action :set_product, only: [:show, :edit, :update]


  #ransackを使って作品を検索した後、ページネーションを使用
  def index
    @search = Product.search(params[:q])#search_formから値を取得
    @products = @search.result.paginate(page: params[:page])
    #@products = Product.search(params[:search])
  end

  def show
    @micropost = current_user.microposts.build if signed_in?
  end

  def new
    @product = Product.new
  end

  def create
    @product=Product.new(product_params)
    if @product.save
      #保存成功の場合
      flash[:success] = "作品の登録に成功しました！"
      redirect_to @product
    else
      #失敗の場合
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

  #ジャンル別で表示する機能
  # TODO :ジャンル別表示のMVCがなんか冗長だからうまいやりかたを考えること
  def original
    genre_search("オリジナル")
  end

  def game
    genre_search("ゲーム")
  end

  def comicanime
    genre_search("漫画・アニメ")
  end

  def noveldramamovie
    genre_search("小説・ドラマ・映画原作")
  end

  def questionnaire
    genre_search("安価")
  end

  def history
    genre_search("歴史")
  end

  def tokusatsu
    genre_search("特撮")
  end

  def knowledge
    genre_search("知識")
  end

  def job
    genre_search("職業")
  end

  def music
    genre_search("音楽")
  end

  def sports
    genre_search("スポーツ")
  end

  def religionmyth
    genre_search("宗教・神話")
  end

  def gourmet
    genre_search("グルメ")
  end

  def shortnotice
    genre_search("短編・予告")
  end

  def rating
    genre_search("【R-18/R-15】")
  end

  def others
    genre_search("その他")
  end

  private
    def set_product
      @product = Product.find(params[:id])
      @microposts = @product.microposts.paginate(page: params[:page])
    end

    def product_params
      params.require(:product).permit(:id, :title, :genre, :link)
    end

    def genre_search(genre)
      @search = Product.search(:genre_cont => genre)
      @products = @search.result.paginate(page: params[:page])
    end
end
