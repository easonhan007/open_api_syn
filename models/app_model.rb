class AppModel < ActiveRecord::Base
	self.abstract_class = true

	def return_fields
		self.class.column_names
	end

	def self.get_required_fields
		[]
	end

	def json_output
		result = {}
		return_fields.each { |f| result[f.to_sym] = self[f] }
		result.to_json
	end

end

