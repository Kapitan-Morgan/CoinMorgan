require 'sinatra'
require 'sinatra/activerecord'
require "./models.rb"

get "/" do
	@posts = Post.all
	erb :index
end

get '/post/:id' do
	@post = Post.find(params[:id])
	erb :post_page
end

get '/create' do
	erb :create
end

# create post
post '/post' do
	@post = Post.create(title: params[:title], body: params[:body])
	redirect '/'
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
	@post = Post.find(params[:id])
	@post.destroy
	redirect '/'
end