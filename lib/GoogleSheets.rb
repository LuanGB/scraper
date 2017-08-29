class GoogleSheets

	def initialize google_auth, spreadsheet_id
		@service = Google::Apis::SheetsV4::SheetsService.new

		@service.authorization = google_auth

		@ss_id = spreadsheet_id
	end

	def append_single_row_on_spreadsheet range, *values
		v = {
			major_dimension: "ROWS",
			values: [
				values
			]
		}

		response = @service.append_spreadsheet_value(
			@ss_id, 
			range, 
			v, 
			value_input_option: 'RAW', 
			insert_data_option: 'INSERT_ROWS'
			)
		
		puts "   Spreadsheet sucessfuly updated at #{response.updates.updated_range}"
		
	end

	def append_on_spreadsheet range, matrix
		v = {
			major_dimension: "ROWS",
			values: matrix
		}

		response = @service.append_spreadsheet_value(
			@ss_id, 
			range, 
			v, 
			value_input_option: 'RAW', 
			insert_data_option: 'INSERT_ROWS'
			)
		
		puts "   Spreadsheet sucessfuly updated at #{response.updates.updated_range}"
		
	end

	def get_value_from_spreadsheet range

		response = @service.get_spreadsheet_value(@ss_id, range)

		response.values
		
	end

	def update_spreadsheet_value range, *values
		v = Google::Apis::SheetsV4::ValueRange.new
		v.major_dimension = 'ROWS'
		v.values = [values]

		response = @service.update_spreadsheet_value(
			@ss_id, 
			range, 
			v,
			value_input_option: 'RAW'
			)
		
		puts "   Spreadsheet sucessfuly updated at #{response.updated_range}"
		
	end

end