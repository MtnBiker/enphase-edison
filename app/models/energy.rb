class Energy < ApplicationRecord
  self.primary_key = "datetime"
  
  before_save :convert_kwh_to_wh # defined below
  
  # https://www.mattmorgante.com/technology/csv
  # and https://gorails.com/episodes/intro-to-importing-from-csv ~2015
  require 'csv'
   
  def self.import_enphase(file)
    puts "#{__LINE__}. file: #{file}. No file to left means file selection not working!" # empty
    # file shouldn't be hard wired, file should be the first variable below
    
    # created file_to_import so could put on notice and to keep separate from file which isn't working
    file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/Enphase Monthly Reports/all_enphase_for.2023.csv" # easier if have to destroy db
    
    # CSV.foreach(file_to_import, headers: false) do |row|
    CSV.foreach(file_to_import, headers: true, header_converters: :symbol) do |row|
      puts "#{__LINE__}. row: #{row}" # the row, no quotes
      # puts "10. row.class: #{row.class}" # CSV::Row
      puts "1#{__LINE__}. row.to_hash #{row.to_hash}" #$ {:datetime=>"2023-11-30 22:15:00 -0800", :enphase=>"0"}. Need to strip the -0800 or whatever
      Energy.create! row.to_hash
    end
  end # def self.import_enphase(file)  
    
  def self.import_edison(file)
    # puts "#{energy.where(from_energy: "2023-12-01 15:15:00")}"
    
    # to line 16 from trying to get id by datetime
    # id_sql = energy.find_by_sql("SELECT id FROM energies WHERE (energies.datetime = '2023-11-30 16:00:00-08')" #undefined local variable or method `energy' for class Energy)
    # id_sql = Energy.find_by_sql("SELECT id FROM energies WHERE datetime = '2023-12-01 15:15:00-08'")
    # id_sql = <<-SQL
    # SELECT id FROM energies WHERE datetime = '2023-12-01 15:15:00-08'
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
        
        if row.flatten.to_s.match(/\"202/)  # Unique to data lines. Good through decade. Works for original export, but not Numbers modified and exported because of double quotes being stripped
          data_line = "Data"
          puts "#{__LINE__}.#{counter}. Data line: #{data_line}. flag: #{flag}"
        else
          data_line = "Not data"
          # puts "#{__LINE__}.#{counter}. Not data line"
        end
        
        # determine datatime and second_col if a data line.
        if data_line
          
          # get datetime and second column which will either be from_sce or to_sce
          puts "#{__LINE__}.#{counter}. row[0] #{row[0]}" # Only getting first element of an array
          puts "#{__LINE__}.#{counter}. row[0].to_s.slice(0..18) #{row[0].to_s.slice(0..18)}" # try to get datetime, then add time zone later
          # Getting time zone
          # Getting first 19 characters and making it a time, which is detecting time zone. Must
          datetime = row[0].to_s.slice(0..18).to_time
          puts "#{__LINE__}.#{counter}. datetime: #{datetime}. datetime.class: #{datetime.class}"
          # puts "#{__LINE__}.#{counter}. datetime.to_time: #{datetime.to_time}. datetime.to_time.class: #{datetime.to_time.class}"
          # puts "#{__LINE__}.#{counter}. utc_offset(datetime): #{datetime.to_time.utc_offset}. utc_to_local(datetime): #{datetime.to_time.utc_to_local}"
          puts "#{__LINE__}.#{counter}. row[0] #{row[0]}" # Only getting first element of an array
          puts "#{__LINE__}.#{counter}. row[0].to_s.slice(0..18) #{row[0].to_s.slice(0..18)}" # try to get datetime, then add time zone later
          # Getting time zone
          # Getting first 19 characters and making it a time, which is detecting time zone. Must
          datetime = row[0].to_s.slice(0..18).to_time
          
          # Second column is either Delivered to customer (from_SCE) or Received from customer (to_SCE) and is determined by subheading in the csv
          second_col = row[1]
          # This seems unnecessarily complex but it works and isn't done often
          if second_col.nil?
            puts "#{__LINE__}.#{counter}. second_col.nil?"
          else
            second_col = second_col.gsub(/[^\d.]/, '').to_f
            second_col = second_col*1000
            # puts "#{__LINE__}.#{counter}. second_col.nil? NOT and second_col.gsub(/[^\d.]/, '').to_f: #{second_col}"
            # second_col = second_col.to_float*1000 @ undefined method `to_float' for an instance of String
          end
          puts "#{__LINE__}.#{counter}. datetime: #{datetime}. datetime.class: #{datetime.class}. second_col: #{second_col} }"
          # puts "#{__LINE__}.#{counter}. datetime.to_time: #{datetime.to_time}. datetime.to_time.class: #{datetime.to_time.class}"
          # puts "#{__LINE__}.#{counter}. utc_offset(datetime): #{datetime.to_time.utc_offset}. utc_to_local(datetime): #{datetime.to_time.utc_to_local}"          
        end
        
        if data_line == "Data" && flag == "Delivered"
          puts "#{__LINE__}.#{counter}. Delivered.  datetime: #{datetime}. from_sce: #{second_col}"
          # Energy.upsert(datetime: datetime, from_sce: second_col, unique_by: :datetime)
          upsert({ datetime: datetime, from_sce: second_col }, unique_by: :datetime)

        elsif data_line == "Data" && flag == "Received"
          datetime = row[0].to_s.slice(0..18).to_time
          puts "#{__LINE__}.#{counter}. Received. to_sce: #{second_col}"

          # Energy.upsert(datetime: datetime, to_sce: second_col)
          upsert({ datetime: datetime, to_sce: second_col }, unique_by: :datetime)
        end
        
      end # CSV.foreach
    puts "#{__LINE__}. Date.today.prev_month(months = 2).beginning_of_month: #{Date.today.prev_month(months = 2).beginning_of_month}\n
    Date.today.last_month.beginning_of_month: #{Date.today.last_month.beginning_of_month}"
  end # def self.import_edison(file)
  
  private
  # https://russt.me/2018/06/saving-calculated-fields-in-ruby-on-rails-5/
  def convert_kwh_to_wh
    self.from_sce = from_sce * 1000 if from_sce.present?
    self.to_sce =   to_sce * 1000 if to_sce.present?
  end
end
