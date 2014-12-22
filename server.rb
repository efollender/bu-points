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
  #response = loadUsers(data[:firebase],data[:slack])
  @content = 'hey there.'
end

post '/info/:user' do
  @user = user_exists?(params[:user], data[:firebase])
end

post '/award-points' do
  request = params
  q = request["text"]
  puts q
  points = /(^[0-9]*)/.match(q)[0].to_i
  user = /(@[\w]*)/.match(q)[0].to_s.gsub(/[@]/,'')
  res = award_points(user,points,data[:firebase])
  return res
  erb :index
end

get '/award-points' do
  request = {
    "text" => '+10 points to @efollender',
  }
  @content = request
  q = request["text"]
  points = q.gsub(/[^0-9]/, '')
  user = /(@[\w]*)/.match(q).to_s.gsub(/[@]/,'')
  res = award_points(user,points,data[:firebase],data[:slack])
  erb :index
end

# post '/remove-points/:user' do
#   q = request["text"]
#   points = request["text"].gsub(/[^0-9]/, '')
#   subtract_points(params[:user],params[:points],data[:firebase],data[:slack])
#   return {username: USERNAME, text: res}
# end

get '/leader' do
  @content = get_leader(data[:firebase],data[:slack])
  erb :index
end