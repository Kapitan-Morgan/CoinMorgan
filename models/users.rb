class User < ActiveRecord::Base
	def test(user)
		user = User.find(session[:id])
	end
end