Labohp::Application.routes.draw do
  #rootをmainpagesコントローラーのindexアクションとテンプレートに設定
  root "main_pages#home"

  #ユーザー登録用リソース
  resources :users do
    member do
      get :following, :followers, :activate
    end
    collection do
      get :thanks_for_signup
    end
  end
  match "/introduction", to: "main_pages#introduction", via: "get"
  match "/signup", to: "users#new", via: "get"
  #サインイン用リソースとルーティング
  resources :sessions, only: [:new, :create, :destroy]
  match "/signin", to: "sessions#new", via: "get"
  match "/signout", to: "sessions#destroy", via: "delete"
  #マイクロポスト用リソース
  resources :microposts , only: [:create, :destroy, :edit, :update] do
    member do
      post :likes
      delete :dislikes
    end
  end

  resources :relationships, only: [:create, :destroy]
  
  resources :products do
    collection do
      get :literature, :love, :history, :mystery, :fantasy, :sf,
          :horror, :comedy, :adventure, :academy, :millitary,
          :fairy_tail, :poem, :essay, :replay, :others,:search_product
    end
    
    member do
      get :create_micropost
    end
  end
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
