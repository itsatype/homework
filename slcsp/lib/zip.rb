class Zip 

	extend CSVParser
  include CSVImporter

	attr_accessor :zipcode, :state, :fips, :name, :rate_area

  @@zips ||= Array.new  

  def initialize(csv_row)
    new_by_csv(csv_row)
    @@zips << self
  end



	def self.lookup(zipcode)
		self.all.select { |zips| zips.zipcode == zipcode }
	end	

  def self.all
    @@zips
  end  

end


