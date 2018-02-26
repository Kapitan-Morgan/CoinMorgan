class SessionsController < ApplicationController
def new 
  
end
def create 
  @user = User.find_by(email: params[:email])
  # If the user exists & the password entered is correct.
  if user && user.authenticate(params[:password])
     session[:user_id] = @user.id
     redirect to ‘/’
   else
     render :’users/signup’
   end
  end
end
def destroy 
  if logged_in?
   session.clear
   redirect to ‘/login’
  else
   redirect to ‘/’
  end
end
end