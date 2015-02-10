require 'pry'
require 'sinatra'
require 'json'
require_relative 'lib/entities.rb'

set :bind, '0.0.0.0'

firebase = {
    :users_uri => 'https://bu.firebaseio.com/users',
    :base_uri => 'https://bu.firebaseio.com/'
  }
USERNAME = 'Dumbledore'
SLACK_TOKEN = 'xoxp-2178724258-3223364896-3264573501-f0d2e1'

get '/' do
  #response = loadUsers(data[:firebase],data[:slack])
  @content = 'hey there.'
end

get '/info/:user' do
  @content = user_exists?(params[:user], firebase)
  erb :index
end

get '/award-points' do
  q = params[:text]
  q = URI.unescape(q)
  points = /(\d\S)/.match(q)[0]
  user = /(@[\w]*)/.match(q)[0].to_s.gsub(/[@]/,'')
  puts points, user
  res = award_points(user,points,firebase)
end

post '/award-points' do
  q = params[:text]
  res = {:text => q }
  return JSON.generate(res)

  # points = /(^[0-9]*)/.match(q)[0].to_i
  # user = /(@[\w]*)/.match(q)[0].to_s.gsub(/[@]/,'')
  # puts points, user
  #res = award_points(user,points,firebase)
  #return res
end

# get '/award-points' do
#   request = {
#     "text" => '+10 points to @efollender',
#   }
#   @content = request
#   q = request["text"]
#   puts q
#   points = q.gsub(/[^0-9]/, '')
#   user = /(@[\w]*)/.match(q).to_s.gsub(/[@]/,'')
#   res = award_points(user,points,firebase)
#   erb :index
# end

# post '/remove-points/:user' do
#   q = request["text"]
#   points = request["text"].gsub(/[^0-9]/, '')
#   subtract_points(params[:user],params[:points],data[:firebase],data[:slack])
#   return {username: USERNAME, text: res}
# end

get '/leader' do
  @content = get_leader(firebase)
  erb :index
end

