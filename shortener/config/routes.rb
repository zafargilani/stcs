Rails.application.routes.draw do
  #get 'urlgencontroller/generate'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'urlgencontroller#index'

  get '/u/:id' => "shortener/shortened_urls#show"
  get '/:id' => "urlgencontroller#show"
  get '/gen/:id' => "urlgencontroller#generate" #of the form /gen/i?u=#{url}
  get '/r/:id' => "urlgencontroller#redirect"

  get '/graph/getjson4clicks' => "urlgencontroller#clicksJson"
  get '/graph/clicks' => "urlgencontroller#getclicks"

  get '/graph/getjson4botornot' => "urlgencontroller#botsJson"
  get '/graph/botornot' => "urlgencontroller#getbotornot"

  get '/graph/getjson4url' => "urlgencontroller#jsongraph4url"
  get '/graph/urlactivity' => "urlgencontroller#geturlactivity"

end
