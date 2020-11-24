Rails.application.routes.draw do

  root  'inheritance#index'

  get  '/inheritance',      to: 'inheritance#query'
  post '/inheritance',      to: 'inheritance#query'
end
