Rails.application.routes.draw do
  root 'static_pages#home'
  get  'static_pages/market'
  get  'static_pages/miners'
end
