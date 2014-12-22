require 'firebase'
require 'httparty'
require 'json'

def loadUsers(firedata, slackdata)
  json = call_slack('users.list',{},slackdata)
  firebase = Firebase::Client.new(firedata[:users_uri])
  json["members"].each do |x|
    if !(user_exists?(x, firedata))
      create = firebase.set(x["name"], { 
        :name => x["name"], 
        :id => x["id"],
        :real_name => x["real_name"],
        :points => 0 
        })
      create.success? ? create.body : 'user exists'
    end
  end
  return 'users loaded.'
end

def call_slack(req, params, slackdata)
  params_string = params.map { |k, v| "#{k}=#{[v].flatten.join('&')}" }.join('&')
  response = HTTParty.get(slackdata[:base_uri] + req + '?' + params_string + 'token=' + slackdata[:token])
  json = JSON.parse(response.body)
  return json
end

def user_exists?(user, firedata)
  firebase = Firebase::Client.new(firedata[:users_uri])
  if user.is_a?(Hash)
    req = user["id"]
  else
    req = user
  end
  response = firebase.get('',{})
  response.body.each do |k,v|
    if v["id"] == user
      return v
    end
  end
  return false
end

def award_points(user, points, firedata)
  firebase = Firebase::Client.new(firedata[:users_uri])
  user_base = user_exists?(user, firedata)
  points = points.to_i
  if user_base["points"]
    points += user_base["points"]
    firebase.update(user_base["name"], {:points => points})
  else
    puts 'user does not exist'
  end
  img = 'http://33.media.tumblr.com/tumblr_m22zhfwzZc1r39xeeo1_500.gif'
  response = 'A total of ' + points.to_s + ' points for ' + user_base["real_name"] +'! ' + img
  res = {
    :text => response
  }
  return JSON.generate(res)
end

def subtract_points(user, caller, points, firedata, slack)
  firebase = Firebase::Client.new(firedata[:users_uri])
  admin = user_exists?(caller, firedata)
  user_base = user_exists?(user, firedata)
  points = points.to_i
  if user_base && admin["name"] == 'efollender'
    user_base["points"] -= points
    firebase.update(user, {:points => user_base["points"]})
  else
    puts 'unauthorized'
  end
end

def get_points(user, firedata, slack)
  firebase = Firebase::Client.new(firedata[:users_uri])
  user_base = user_exists?(user, firedata)
  if user_base
    return user_base["points"]
  else
    puts 'user does not exist'
  end
end

def get_leader(firedata, slack)
  firebase = Firebase::Client.new(firedata[:base_uri])
  users = firebase.get('users')
  leader = {'points' => 0}
  users.body.each do |k,v|
    if v['points'] > leader['points']
      leader = v
    end
  end
  return leader
end
