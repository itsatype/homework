require_relative '../lib/csv_importer'
require_relative '../lib/csv_parser'
require_relative '../lib/plan'
require_relative '../lib/zip'
require_relative '../lib/plan_finder'

RSpec.configure do |config|
  # Use color in STDOUT
  config.color = true
  config.formatter = :documentation
 end