Rails.application.routes.draw do
  mount Spree::Core::Engine, at: '/'

  root 'vue#viewer', defaults: {format: 'html'}
  get '/:name(.:format)' => 'vue#viewer', as: :front_end

  resource :wx, :controller => "vue", only: [:show, :create] do
    post 'notify'
  end

  namespace :resource do
    resource :handle, only: [:show, :create]
  end

  Spree::Core::Engine.add_routes do
    namespace :admin do
    end

    namespace :api, defaults: {format: 'json'} do
      namespace :v2 do
        resource :wx_users, only: [:show] do
          get '/up_token' => 'wx_users#up_token'
        end
      end
    end
  end
end
