Rails.application.routes.draw do
#  get "home/index/:code" => "home#index"
  get "home/index" => "home#index"
  get 'home/show' => "home#show"
  get 'home/destroy/' => "home#destroy"
  get 'home/move/' => "home#move"

  root :to => 'home#index'
end
