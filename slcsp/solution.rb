require 'pry'
require 'csv'

class PlanFinder 
	attr_reader :zips, :plans, :slcsp_rate
	
	def initialize
		read_file('plans.csv')
		read_file('zips.csv')
		slcsp_for_csv_zipcodes('slcsp.csv')
	end

	def find_plans_for_zip(zipcode)
		@zips = zip_finder(zipcode)
		@plans = plan_finder if zips.count == 1 || same_zip_rate_area?
		@slcsp_rate = find_slcsp.rate if plans.any?
	end

	def slcsp_for_csv_zipcodes(path)
		csv_rows = CSV.read(path, headers: true)
		csv_rows.each do |csv_row| 
			zipcode = csv_row["zipcode"]
			find_plans_for_zip(zipcode)
			CSV.open("test.csv", "ab") { |csv| csv << [zipcode, slcsp_rate] }
		end
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

	def zip_finder(zipcode)
		Zip.all.select { |zips| zips.zipcode == zipcode }
	end

	def plan_finder
		Plan.all.select do |plan| 
			plan.state == zips.first.state && plan.rate_area == zips.first.rate_area && plan.metal_level == "Silver"
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

end

PlanFinder.new