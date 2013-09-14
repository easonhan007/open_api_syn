class User < AppModel
	validates :name, :password, :presence => true

	def self.return_fields
		'id, name'
	end
end

