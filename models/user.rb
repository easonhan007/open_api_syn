class User < AppModel
	validates :name, :password, :presence => true
end

