require_relative 'spec_helper'

describe Zip do 

	let(:zip) { Zip.new({"zipcode"=>"10977", "state"=>"NY", "rate_area"=>"1"}) }
	let(:zip2) { Zip.new({"zipcode"=>"10952", "state"=>"NY", "rate_area"=>"2"}) }


	describe "#initialize" do
		it "creates an object from a csv row" do
			expect(zip.zipcode).to eq ("10977")
			expect(zip2.state).to eq ("NY")

		end
	end

	describe "#initialize with @@all" do
		it "saves an object after initialization" do
			expect(Zip.all.size).to eq (2)
		end
	end

	describe ".lookup" do
		it "finds all zipcodes instances, given a Zipcode" do
			zips_found = Zip.lookup('10977')
			expect(zips_found.size).to eq (1)
		end
	end	

end


describe Plan do 

	let(:plan) { Plan.new({"plan_id"=>"74449NR9870320", "state"=>"NY", "metal_level"=>"Silver", "rate_area"=>"1"}) }
	let(:plan2) { Plan.new({"plan_id"=>"18378UN5835046", "state"=>"TX", "metal_level"=>"Gold", "rate_area"=>"1"}) }
	
	let(:zip) { Zip.new({"zipcode"=>"10977", "state"=>"NY", "rate_area"=>"1"}) }


	describe "#initialize" do
		it "creates an object from a csv row" do
			expect(plan.plan_id).to eq ("74449NR9870320")
			expect(plan2.state).to eq ("TX")
		end
	end

	describe "#initialize with @@all" do
		it "saves an object after initialization" do
			expect(Plan.all.size).to eq (2)
		end
	end

	describe ".lookup" do
		it "finds all plan instances associated with a rate_area & state, given a Zipcode object" do
			plans_found = Plan.lookup(zip)
			expect(plans_found.size).to eq (1)
		end
	end	

end


describe PlanFinder do 

	let(:planfinder) { PlanFinder.new({"zipcode"=>"10977", "rate"=>""}) }
	
	let(:plan) { Plan.new({"plan_id"=>"74449NR9870320", "state"=>"NY", "metal_level"=>"Silver", "rate_area"=>"1", "rate"=>"100"}) }
	let(:plan2) { Plan.new({"plan_id"=>"18378UN5835046", "state"=>"NY", "metal_level"=>"Silver", "rate_area"=>"1",  "rate"=>"110"}) }
	
	let(:zip) { Zip.new({"zipcode"=>"10977", "state"=>"NY", "rate_area"=>"1"}) }
	let(:zip2) { Zip.new({"zipcode"=>"10977", "state"=>"NY", "rate_area"=>"2"}) }


	describe "#initialize with @plans" do
		it "assigns an empty array of plans on initialization, to account for zipcodes without plans" do
			expect(planfinder.plans).to eq ([])
		end
	end

	
	describe "#find_slcsp" do
		it "finds the second lowest silver plan rate for a zipcode" do
			planfinder.plans = [plan, plan2]
			rate_found = planfinder.find_slcsp
			expect(rate_found.rate).to eq ("110")
		end
	end


	describe "#same_zip_rate_area?" do
		it "returns false if there are multipe zipcodes with different rate areas" do
			planfinder.zips = [zip, zip2]			
			expect(planfinder.same_zip_rate_area?).to be_falsey
		end
		it "returns true if there are multipe zipcodes with the same rate areas" do
			zip2.rate_area = "1"
			planfinder.zips = [zip, zip2]			
			expect(planfinder.same_zip_rate_area?).to be_truthy
		end			
	end

	describe "#find_plans_for_zip" do
		it "doesn't look up the plans if there are multipe zip instances with different rate areas" do
			planfinder.find_plans_for_zip
			expect(planfinder.plans).to eq ([])
		end	
	end

end