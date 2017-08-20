Rails.application.routes.draw do
  namespace :callbacks do
    resource :ccbill, only: [:show, :create]
  end
end
