class AppModel < ActiveRecord::Base
	self.abstract_class = true

	class << self
		# return fields for get request
		def return_fields
			self.class.column_names.join(',')
		end

		def get_required_fields
			[]
		end

		def create_required_fields
			[]
		end

		def update_required_fields
			[]
		end

		def build_like_fields(params)
			model_like_fields = self.like_fields rescue []
			like_fields = []
			unless model_like_fields.is_a?(Array) and model_like_fields.empty?
				model_like_fields.each { |f| like_fields << params.delete(f) }
			end
		end

		def build_in_fields
		end

	end 

end

