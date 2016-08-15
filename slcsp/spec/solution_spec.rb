require_relative 'spec_helper'

describe PlanFinder do
	 
	 plan_finder = PlanFinder.new

  it "finds all zipcodes for a given zipcode" do
  	zipcodes = plan_finder.zips
  	expect(zipcodes.count).to eq (3)
  end

  it "finds all plans for a given zipcode" do
  end
end