require 'sinatra'
require 'sinatra/activerecord'
require "./models/models.rb"
require "./models/users.rb"

enable :sessions

get "/" do
	@user = User.find(session[:id]) if session[:id]
	a = Post.all
	@posts = a.find_all{|e| e[:owner_id] == @user[:id]}
	erb :index
end

get '/post/:id' do
	@user = User.find(session[:id]) if session[:id]
	@post = Post.find(params[:id])
	erb :post_page
end

get '/create' do
	@user = User.find(session[:id]) if session[:id]
	erb :create
end

post '/registrations' do
	a = User.find_by(name: params[:name])
	unless a
		@user = User.create(name: params[:name], email: params[:email], password: params[:password])
		session[:id] = @user.id
		redirect '/users/home'
	else
		erb :'eror/dont_name'
	end
end

get '/users/home' do
	puts session[:id]
	@user = User.find(session[:id]) if session[:id]
	erb :'users/home'
end

get '/registrations/signup' do
	@user = User.find(session[:id]) if session[:id]
	erb :registrations
end

get '/sessions/login' do
	@user = User.find(session[:id]) if session[:id]
	puts session
	erb :'users/login'
end

post '/sessions' do
	@user = User.find_by(email: params[:email], password: params[:password])
	if @user != nil
		session[:id] = @user.id
		redirect 'users/home'
	else
		erb :'eror/session_eror'
	end
end

get '/sessions/logout' do
	session.clear
	redirect '/'
end

# create post
post '/post' do
	if session[:id]
		@user = User.find(session[:id])
		@post = Post.create(title: params[:title], body: params[:body], owner_id: @user[:id])
		redirect '/'
	else
		erb :'/sessions/login'
	end
end

# update post
put '/post/:id' do
	@post = Post.find(params[:id])
	@post.update(title: params[:title], body: params[:body])
	@post.save
	redirect '/post/'+params[:id]
end

# delete post
delete '/post/:id' do
	@user = User.find(session[:id]) if session[:id]
	if @user != nil
		if @user[:name] == 'Admin'
			@post = Post.find(params[:id])
			@post.destroy
			redirect '/'
		else
			erb :'eror/no_access'
		end
	else
		erb :'eror/no_access'
	end
end 