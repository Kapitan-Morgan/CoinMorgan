class UserController < ApplicationController
get ‘/signup’ do
  if !logged_in?
   @user = User.new
   erb :’users/signup’
  else
   redirect to ‘/tips’
  end
 end
post ‘/signup’ do
  @user = User.new(username: params[:username], password: params[:password], password_confirmation: params[:confirm_password], email: params[:email])
  if @user.save
   session[:user_id] = @user.id
   redirect to ‘/tips’
  else
  erb :’users/signup’
   end
 end
get ‘/login’ do
  if !logged_in?
   erb :’users/login’
  else
   redirect to ‘/’
  end
 end
post ‘/login’ do
  user = User.find_by(username: params[:username])
  if user && user.authenticate(params[:password])
   session[:user_id] = user.id
   redirect to '/'
  end
 end
get ‘/logout’ do
  if logged_in?
   session.clear
   redirect to ‘/login’
  else
   redirect to ‘/’
  end
 end
end