module CSVImporter

  def new_by_csv(csv_row)
    csv_row.each do |attribute, value| 
      instance_variable_set("@#{attribute}", value) 
    end
  end

end  
