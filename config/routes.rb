TheRottenPirate::Application.routes.draw do
  resources :downloads
  match '/check' => 'downloads#check'
  root :to => 'downloads#new'
end
