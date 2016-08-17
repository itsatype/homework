require 'pry'
require 'csv'

module CSVParser

	def csv_rows_to_object(path)
    csv_rows = CSV.read(path, headers: true)
		csv_rows.each do |csv_row|
			self.new(csv_row.to_hash)
		end
	end

end

module CSVImporter

  def new_by_csv(csv_row)
    csv_row.each do |attribute, value| 
      instance_variable_set("@#{attribute}", value) 
    end
  end

end  

class PlanFinder
	
	extend CSVParser
  include CSVImporter
	
	attr_accessor :zips, :plans, :rate, :zipcode
	
  @@all ||= Array.new  

  def initialize(csv_row)
    new_by_csv(csv_row)
    @plans = []
    @@all << self
  end

  def self.write_to_csv
    CSV.open("test.csv", "ab") do |csv|
      self.all.each { |plan| csv << [plan.zipcode, plan.rate] }
    end
  end

	def self.lookup
    self.all.each { |plan_finder| plan_finder.find_plans_for_zip }
	end


	def find_plans_for_zip
		@zips = Zip.lookup(zipcode)
		@plans = Plan.lookup(zips.first) if zips.count == 1 || same_zip_rate_area?
 		@rate = find_slcsp.rate if plans.any? 
	end


	def same_zip_rate_area?
		zips.collect { |zip| zip.rate_area }.uniq.count == 1
		#account for different states but same rate_area
	end

	def find_slcsp
		plans.sort_by { |plan|	plan.rate }[1]
	end

  def self.all
    @@all
  end

end

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



def run
  Plan.csv_rows_to_object('plans.csv')
  Zip.csv_rows_to_object('zips.csv')
  PlanFinder.csv_rows_to_object('slcsp.csv')
  PlanFinder.lookup 
  PlanFinder.write_to_csv
end

# run