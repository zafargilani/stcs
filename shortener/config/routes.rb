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

  get '/graph/graphs' => "urlgencontroller#getGraphs"
  get '/graph/clicksjson' => "urlgencontroller#clicksJson"
  get '/graph/botsjson' => "urlgencontroller#botsJson"
  get '/graph/bottypesjson' => "urlgencontroller#bottypesJson"
  get '/graph/urljson' => "urlgencontroller#urlJson"

end
