class User < ActiveRecord::Base
	validates :email, :format => {:with => /\w+@\w+\.\w+/}
	validates :password_digest, length: { minimum: 6 }
	has_secure_password
	has_many :posts
end