require 'pry'
require 'csv'

class PlanFinder 
	
	attr_reader :zips, :plans, :slcsp_rate
	
	def initialize
		read_file('plans.csv')
		read_file('zips.csv')
		slcsp_for_csv_zipcodes('slcsp.csv')
	end

	def slcsp_for_csv_zipcodes(path)
		csv_rows = CSV.read(path, headers: true)
		csv_rows.each do |csv_row| 
			zipcode = csv_row["zipcode"]
			find_plans_for_zip(zipcode)
			CSV.open("test.csv", "ab") { |csv| csv << [zipcode, slcsp_rate] }
		end
	end


	def find_plans_for_zip(zipcode)
		@zips = Zip.lookup(zipcode)
		@plans = Plan.lookup(zips.first) if zips.count == 1 || same_zip_rate_area?
		@slcsp_rate = find_slcsp.rate if plans.any?
	end


	def same_zip_rate_area?
		zips.collect { |zip| zip.rate_area }.uniq.count == 1
		#account for different states but same rate_area
	end


	def read_file(path)
		csv_rows = CSV.read(path, headers: true)
		csv_rows.each do |csv_row|
			path == 'plans.csv' ? Plan.new(csv_row.to_hash) : Zip.new(csv_row.to_hash)
		end
	end



	def find_slcsp
		plans.sort_by { |plan|	plan.rate }[1] 
	end

end

class Plan

	attr_accessor :plan_id, :state, :metal_level, :rate, :rate_area

	@@all ||= Array.new

	def initialize(csv_row)
		csv_row.each do |attribute, value| 
			instance_variable_set("@#{attribute}", value)
		end
		@@all << self
	end

	def self.all
		@@all
	end


	def self.lookup(zipcode)
		self.all.select do |plan| 
			plan.state == zipcode.state && plan.rate_area == zipcode.rate_area && plan.metal_level == "Silver"
		end
	end	

end


class Zip

	attr_accessor :zipcode, :state, :fips, :name, :rate_area

	@@all ||= Array.new

	def initialize(csv_row)
		csv_row.each do |attribute, value| 
			instance_variable_set("@#{attribute}", value)
		end
		@@all << self
	end

	def self.all
		@@all
	end

	def self.lookup(zipcode)
		self.all.select { |zips| zips.zipcode == zipcode }
	end	

end
