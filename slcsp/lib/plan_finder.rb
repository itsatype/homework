require 'csv'

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

  def self.write_to_csv(path)
    CSV.open(path, "ab") do |csv|
      self.all.each { |plan| csv << [plan.zipcode, plan.rate] }
    end
    puts "Success! The file for all #{self.all.count} zipcodes has been created. Check it out in #{path} :)"
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
	end

	def find_slcsp
		plans.sort_by { |plan|	plan.rate }[1]
	end

  def self.all
    @@all
  end

end