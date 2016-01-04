Rails.application.routes.draw do
  get 'bot/info'

  root 'static_pages#home'
  get    'market'    => 'static_pages#market'
  get    'miners'   => 'static_pages#miners'
  get    'hashnest_s7' => 'static_pages#hashnest_s7'
  get    'hashnest_s5' => 'static_pages#hashnest_s5'
  get    'hashnest_s4' => 'static_pages#hashnest_s4'
  get    'hashnest_s3' => 'static_pages#hashnest_s3'
  post '/miners' => 'static_pages#miners'
end
