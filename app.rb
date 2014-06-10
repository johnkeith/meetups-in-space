require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

def registered?(meetup_id)
  result = UsersAtMeetup.where("user_id = ? AND meetup_id = ?", current_user, meetup_id)
  result.empty? ? false : true
end

get '/' do
  redirect '/meetups'
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end


get '/meetups' do
  @meetups = Meetup.all.order("lower(name)")
  erb :'/meetups/index' 
end

get '/meetups/new' do
  authenticate!
  erb :'/meetups/new'
end

post '/meetups/new' do
  Meetup.create(name: params[:name], description: params[:description], location: params[:location])
  id = Meetup.where(name: params[:name]).first.id
  flash[:notice] = "Successfully created new event"
  redirect "/meetups/show/#{id}"
end

post '/meetups/show' do
  # @meetup = Meetup.find(params[:id])
  if registered?(params[:meetup_id])
    UsersAtMeetup.where(user_id: params[:user_id], meetup_id: params[:meetup_id]).delete_all
    flash[:notice] = "You have left the meetup!"
  else
    UsersAtMeetup.create(user_id: params[:user_id], meetup_id: params[:meetup_id])
    flash[:notice] = "You have joined the meetup!"
  end
  redirect "/meetups/show/#{params[:meetup_id]}"
end

get '/meetups/show/:id' do
  @id = params[:id]
  @meetup = Meetup.find(params[:id])
  @attending = @meetup.users
  erb :'/meetups/show'
end
