class Plan 

	extend CSVParser
  include CSVImporter

	attr_accessor :plan_id, :state, :metal_level, :rate, :rate_area

	@@plans ||= Array.new

	def initialize(csv_row)
		new_by_csv(csv_row)
    @@plans << self
	end


	def self.lookup(zipcode)
		self.all.select do |plan| 
			plan.state == zipcode.state && plan.rate_area == zipcode.rate_area && plan.metal_level == "Silver"
		end
	end	

  def self.all
    @@plans
  end  

end
