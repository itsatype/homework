require 'csv'

module CSVParser

	def csv_rows_to_object(path)
    csv_rows = CSV.read(path, headers: true)
		csv_rows.each do |csv_row|
			self.new(csv_row.to_hash)
		end
	end

end