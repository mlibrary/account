require 'sinatra'
require 'sinatra/json'
require 'byebug'

get "/v1/users/:uniqname" do
  user = JSON.parse(File.read('./tutor_user.json'))
  user["uniqname"] = params[:uniqname]
  json user
end
get "/v1/users/:uniqname/loans" do
  json JSON.parse(File.read('./tutor_history.json'))
end
put "/v1/users/:uniqname" do
  body = JSON.parse(request.body.read)
  user = JSON.parse(File.read('./tutor_user.json'))
  user["uniqname"] = params[:uniqname]
  user["retain_history"] = body["retain_history"]
  json user
end
