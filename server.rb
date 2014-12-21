require 'sinatra'
require_relative 'lib/entities.rb'

set :bind, '0.0.0.0'

data = {
  :firebase => {
    :users_uri => 'https://bu.firebaseio.com/users',
    :base_uri => 'https://bu.firebaseio.com/'
  },
  :slack => {
    :base_uri => 'https://slack.com/api/'
  }
}
USERNAME = 'Dumbledore'

get '/' do
  response = loadUsers(data[:firebase],data[:slack])
  @response = response
  erb :index
end

post '/info/:user' do
  @user = user_exists?(params[:user], data[:firebase])
end

post '/award-points/' do
  q = request["text"]
  points = q.gsub(/[^0-9]/, '')
  user = /(@[a-zA-Z]*)/.match(q).to_s.gsub(/[@]/,'')
  res = award_points(user,points,data[:firebase],data[:slack])
  return {username: USERNAME, text: res}
end

# post '/remove-points/:user' do
#   q = request["text"]
#   points = request["text"].gsub(/[^0-9]/, '')
#   subtract_points(params[:user],params[:points],data[:firebase],data[:slack])
#   return {username: USERNAME, text: res}
# end

post '/leader' do
  @user = get_leader(data[:firebase],data[:slack])
end