require 'pry'

require_relative 'csv_importer'
require_relative 'csv_parser'
require_relative 'plan'
require_relative 'zip'
require_relative 'plan_finder'

def run
  Plan.csv_rows_to_object('../plans.csv')
  Zip.csv_rows_to_object('../zips.csv')
  PlanFinder.csv_rows_to_object('../slcsp.csv')
  PlanFinder.lookup 
  PlanFinder.write_to_csv('solution.csv')
end

run