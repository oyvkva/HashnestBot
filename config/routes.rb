Rails.application.routes.draw do

  root 'bot#start'
  post '/' => 'bot#start'

end
