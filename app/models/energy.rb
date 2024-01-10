class Energy < ApplicationRecord
  self.primary_key = "datetime"
  
  before_save :convert_kwh_to_wh # defined below
  
  # https://www.mattmorgante.com/technology/csv
  # and https://gorails.com/episodes/intro-to-importing-from-csv ~2015
  require 'csv'
   
  def self.import_enphase(file)
    puts "#{__LINE__}. file: #{file}. No file to left means file selection not working!" # empty
    # file shouldn't be hard wired, file should be the first variable below
    # CSV.foreach(file, headers: true) do |row| # no implicit conversion of nil into String
    # created file_to_import so could put on notice and to keep separate from file which isn't working
    file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/Enphase Monthly Reports/4692581_monthly_energy_report.2023.10.csv"
    # CSV.foreach(file_to_import, headers: false) do |row|
    CSV.foreach(file_to_import, headers: true, header_converters: :symbol) do |row|
      puts "#{__LINE__}. row: #{row}" # the row, no quotes
      # puts "10. row.class: #{row.class}" # CSV::Row
      puts "1#{__LINE__}. row.to_hash #{row.to_hash}" #$ {:datetime=>"2023-11-30 22:15:00 -0800", :enphase=>"0"}. Need to strip the -0800 or whatever
      Energy.create! row.to_hash
    end
  end # def self.import(file)
  
    
  def self.import_edison(file)
    # puts "#{energy.where(from_energy: "2023-12-01 15:15:00")}"
    
    # to line 16 from trying to get id by date_hour
    # id_sql = energy.find_by_sql("SELECT id FROM energies WHERE (energies.date_hour = '2023-11-30 16:00:00-08')" #undefined local variable or method `energy' for class Energy)
    # id_sql = Energy.find_by_sql("SELECT id FROM energies WHERE date_hour = '2023-12-01 15:15:00-08'")
    # id_sql = <<-SQL
    # SELECT id FROM energies WHERE date_hour = '2023-12-01 15:15:00-08'
    # SQL
    # puts "#{__LINE__}. id_sql: #{id_sql}"
    
    flag = "Not a data line" # persists if defined here. Will be Not yet until hits first local heading. Could be "", but helps a bit to have a value for debugging
    data_line = "Not data"
  
    puts "#{__LINE__}. file: #{file}. No file to left means file selection not working!" # empty
      # file shouldn't be hard wired, file should be the first variable below
      # created file_to_import so could put on notice and to keep separate from file which isn't working
      # Energy_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/01 Dec 23 to 01 Jan 24.Received added to right.csv"
      # sce_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/01 Dec 23 to 01 Jan 24.original LibreOffice.csv"
      sce_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/LibreOffice.test_short.2023.11.csv"
      counter = 0
      row_slice_previous = "Haven't found a data row yet"
     
      CSV.foreach(sce_file_to_import, headers: false) do |row|
        date_hour, from_sce, to_sce = row # not quite sure this is going to work
        puts "\n#{__LINE__}.#{counter += 1}. row: #{row}. row.class: #{row.class}" # All Arrays, some empty—the blank rows
        # puts "\n#{__LINE__}. row&.nonzero?: #{row&.nonzero}" # NoMethodError (undefined method `nonzero' for an instance of Array): even on line 2? Even though it is an Array and not empty
        # puts "#{__LINE__}.#{counter}. row[0]: #{row[0]}. Some parsing of above." if (row.is_a? Array) && (row.any?) # The if works on all. Blank rows skipped
        # flag = "Delivered" if row.match(/Delivered/) # NoMethodError (undefined method `match' for an instance of Array) 
        # puts "#{__LINE__}.#{counter}. row.to_s: #{row.to_s}" # Only getting first element of an array
       
        # puts "#{__LINE__}.#{counter}. row.flatten.to_s: #{row.flatten.to_s}" 
        # flag = "Delivered" if row.to_s.match(/Delivered/) # NoMethodError (undefined method `match' for an instance of Array) 
        # flag = "Delivered" if row.flatten.match(/Delivered/) # undefined method `match' for an instance of Array for row 3
        
        # Determining if next batch of data is Delivered or Received 
        # flag = "Delivered" if row.flatten.to_s.match(/Delivered/) # this works with as exported from SCE but not exported from Numbers
        # flag = "Delivered" if row[0].match(/Delivered/) #Works for original export, but not Numbers modified and exported because of double quotes being stripped
        flag = "Delivered" if row[0].match(/Delivered/)
        flag = "Received" if row.flatten.to_s.match(/Received/) # If Received in header won't import with this logic
        if row.flatten.to_s.match(/\"202/)    # Unique to data lines. Good through decade. Works for original export, but not Numbers modified and exported because of double quotes being stripped
          data_line = "Data"
          puts "#{__LINE__}.#{counter}. Data line: #{data_line}. flag: #{flag}" # No change needed for csv exported from Numbers
        else
          data_line = "Not data"
          # puts "#{__LINE__}.#{counter}. Not data line"
        end
           
        # puts "#{__LINE__}.#{counter}. flag: #{flag}. #{data_line}" # flag not persisting define outside loop?
        
        #### Can I convert to with time zone. By default the time is put in as -8 but with the local time. #### 
        # puts "#{__LINE__}.#{counter}. Just before enter if data_line" # 
        if data_line == "Data" && flag == "Delivered"
          puts "#{__LINE__}.#{counter}. row[0] #{row[0]}" # Only getting first element of an array
          puts "#{__LINE__}.#{counter}. row[0].to_s.slice(0..18) #{row[0].to_s.slice(0..18)}" # try to get date_hour, then add time zone later
          # Getting time zone
          # Getting first 19 characters and making it a time, which is detecting time zone. Must
          date_hour = row[0].to_s.slice(0..18).to_time
          puts "#{__LINE__}.#{counter}. date_hour: #{date_hour}. date_hour.class: #{date_hour.class}"
          # puts "#{__LINE__}.#{counter}. date_hour.to_time: #{date_hour.to_time}. date_hour.to_time.class: #{date_hour.to_time.class}"
          # puts "#{__LINE__}.#{counter}. utc_offset(date_hour): #{date_hour.to_time.utc_offset}. utc_to_local(date_hour): #{date_hour.to_time.utc_to_local}"
          
          # time_zone = "-0800" # need to calculate this by time of year
          # date_hour = "#{row[0].to_s.slice(0..18)} #{time_zone}"
  
          # date_hour, from_sce, to_sce = row
          # puts "#{__LINE__}.#{counter}. Delivered. from_sce: #{from_sce}. to_sce: #{to_sce}"
          # to_sce = "xxx" # Why is this needed? And how to get around. Maybe undo NOT NULL in db. Yes that does it
          puts "#{__LINE__}.#{counter}. date_hour: #{date_hour}. Delivered. from_sce: #{from_sce}. to_sce: #{to_sce}"
          sce = Sce.create(date_hour: date_hour, from_sce: from_sce, to_sce: to_sce) # sce = for elsif which at the moment isn't being used
          # data_line = "Not data" # unset and is set on each run through. Could change that statement line 32 if then else. TODO. That would be cleaner
          # Not using as have combined data, but still need above because there is a section for Received in the data, so need to skip 
        elsif data_line == "Data" && flag == "Received" # Doing nothing since now using modified original file, but trying to make it work so don't have to modify original file
          # date_hour, to_sce = row
          date_hour = row[0].to_s.slice(0..18).to_time
          puts "#{__LINE__}.#{counter}. Received. to_sce: #{to_sce}"
          # Doesn't know which item to update. Can I get the id say by date_hour which is unigue and then update that id. Can't make work. Even in irb, although can get id in PGAdmin as follows
          # enphase = find_by_sql("SELECT enphase FROM energies WHERE datetime = '2023-12-01 15:15:00-08';")
          # enphase = find_by_sql("SELECT enphase FROM energies WHERE datetime = '#{date_hour}'") # can't get the syntax
          # enphase = where energy('datetime = ?', date_hour) # energy: undefined method `energy'
          # puts "#{__LINE__}.#{counter}. enphase: #{enphase}"
          # The following two lines should be equivalent, but the return (result) is not 237
          # SELECT enphase FROM energies WHERE datetime = '2023-12-01 15:15:00-08'; -- 237 
          # Energy.find_by datetime: '2023-12-01 15:15:00-08'
          energ = Energy.find_by datetime: date_hour # returns an object of class: Energy
          puts "#{__LINE__}.#{counter}. energ.inspect: #{energ.inspect}" # #<Energy datetime: "2023-12-31 23:30:00.000000000 -0800", enphase: 0.0>
          
          energ_to_s = energ.to_s
          #  enphase[0]: {enphase[0]} doesn't not error but doesn't return anything
          puts "#{__LINE__}.#{counter}. energ: #{energ} for datetime = #{date_hour}. energ.class: #{energ.class}. energ_to_s: #{energ_to_s}" # 96.6235. enphase: #<Energy:0x0000000131c76550> for datetime = 2023-12-31 23:45:00 -0800. enphase.class: Energy. enphase[0]: . energ_to_s: #<Energy:0x0000000131c76550>
          # puts "#{__LINE__}.#{counter}. enphase: #{enphase} for datetime = #{date_hour}. Energy.enphase: #{Energy.enphase}
          # Sting = [#<Sce enphase: 237.0, date_hour: nil>]
          # str = "[#<Sce enphase: 237.0, date_hour: nil>]"
          matches =  energ_to_s.scan(/\b\d+\b/)
          
          puts "#{__LINE__}. matches.inspect: #{matches.inspect}. matches.class: #{matches.class}. matches[0]: #{matches[0]}"
          # enphase: [#<Sce datetime: "2023-12-01 23:15:00.000000000 +0000", enphase: 237.0, date_hour: nil>] for datetime = '2023-12-01 15:15:00-08'. enphase0: #<Sce:0x0000000131e9c960>
          wha = find_by_sql("SELECT * FROM energies WHERE datetime = '2023-12-01 15:15:00-08';") # same object_id as enphase on line 103, but enphase.class is Energy and wha.class: Array
          puts "#{__LINE__}.#{counter}. wha: #{wha} for datetime = '2023-12-01 15:15:00-08'. wha.class: #{wha.class}.  wha[0]: #{wha[0]}. wha[1]: #{wha[1]}" #   wha: [#<Sce enphase: 237.0, date_hour: nil>] for datetime = '2023-12-01 15:15:00-08'. wha.class: Array. wha[0]: #<Sce:0x0000000130d1ce60>. wha[1]: . wha.enphase: #{wha.enphase}. error undefined method `enphase' for an instance of Array
          sce =  Sce.where(date_hour: date_hour)
          puts "#{__LINE__}.#{counter}. sce: #{sce}"
          # sce = sce.update(date_hour: date_hour, to_sce: to_sce)
          # # null value in column "to_sce" of relation "energies" violates not-null constraint. Changed to 0.001 to see if that's the issue
          # data_line = "Not data" # unset so comparison above works
        # else
        #   puts "#{__LINE__}.#{counter}. Not a data line to be processed"
        end
        
      end # CSV.foreach
    puts "#{__LINE__}. Date.today.prev_month(months = 2).beginning_of_month: #{Date.today.prev_month(months = 2).beginning_of_month}\n
    Date.today.last_month.beginning_of_month: #{Date.today.last_month.beginning_of_month}"
  end # def self.import(file)
  
  private
  # https://russt.me/2018/06/saving-calculated-fields-in-ruby-on-rails-5/
  def convert_kwh_to_wh
    self.from_sce = from_sce * 1000 if from_sce.present?
    self.to_sce =   to_sce * 1000 if to_sce.present?
  end
end
