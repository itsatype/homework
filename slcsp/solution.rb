require 'pry'
require 'csv'

module ParseCSV

	def csv_rows_to_object(path)
    csv_rows = CSV.read(path, headers: true)
		csv_rows.each do |csv_row|
			self.new(csv_row.to_hash)
		end
	end

end

module Init

  def init(csv_row)
    csv_row.each do |attribute, value| 
      instance_variable_set("@#{attribute}", value) 
    end
  end

end  

class PlanFinder
	
	extend ParseCSV
  include Init
	
	attr_accessor :zips, :plans, :rate, :zipcode
	
  @@all ||= Array.new  

  def initialize(csv_row)
    init(csv_row)
    @plans = []
    @@all << self
  end


	def self.lookup
    self.all.each do |plan_finder|
      plan_finder.find_plans_for_zip
			CSV.open("test.csv", "ab") { |csv| csv << [plan_finder.zipcode, plan_finder.rate] }
		end
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

	extend ParseCSV
  include Init

	attr_accessor :plan_id, :state, :metal_level, :rate, :rate_area

	@@all ||= Array.new

	def initialize(csv_row)
		init(csv_row)
    @@all << self
	end


	def self.lookup(zipcode)
		self.all.select do |plan| 
			plan.state == zipcode.state && plan.rate_area == zipcode.rate_area && plan.metal_level == "Silver"
		end
	end	

  def self.all
    @@all
  end  

end


class Zip 

	extend ParseCSV
  include Init

	attr_accessor :zipcode, :state, :fips, :name, :rate_area

  @@all ||= Array.new  

  def initialize(csv_row)
    init(csv_row)
    @@all << self
  end



	def self.lookup(zipcode)
		self.all.select { |zips| zips.zipcode == zipcode }
	end	

  def self.all
    @@all
  end  

end



def run
  Plan.csv_rows_to_object('plans.csv')
  Zip.csv_rows_to_object('zips.csv')
  PlanFinder.csv_rows_to_object('slcsp.csv')
  PlanFinder.lookup 
end

run