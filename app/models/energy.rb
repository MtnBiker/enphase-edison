class Energy < ApplicationRecord
  self.primary_key = "datetime"
  acts_as_hypertable time_column: :datetime # default is created_at https://github.com/jonatas/timescaledb?tab=readme-ov-file#enable-actsashypertable

# https://docs.timescale.com/quick-start/latest/ruby/create-scopes-to-reuse
 scope :last_month, -> { where('datetime > ?', 1.month.ago) }
 scope :last_year, -> { where('datetime > ?', 1.year.ago) }
 # in rails console: Energy.last_month.all for example
 
 # ChatGPT
 # Use with: result = Energy.monthly_summary
 def self.monthly_summary
   select(
     time_bucket('1 month', datetime) AS monthly_interval,
     SUM(enphase)/1000 AS enphase,
     SUM(from_sce)/1000 AS from_sce,
     SUM(to_sce)/1000 AS to_sce,
     (SUM(enphase) + SUM(from_sce) - SUM(to_sce))/1000 AS used
   )
   .group("monthly_interval")
   .order("monthly_interval")
   # .limit(10).offset(5) # No effect in rc
 end

# https://docs.timescale.com/quick-start/latest/ruby/#create-scopes-to-reuse
# This may not be close enough to what I'm doing to use as an example
  # scope :per_hour, -> { time_bucket('1 hour') }
  # scope :per_day, -> { time_bucket('1 day') }
  # scope :per_month, -> { time_bucket('1 month') }
  # scope :average_response_time_per_hour, -> { time_bucket('1 hour', value: 'avg(performance)') }
  # scope :worst_response_time_last_minute, -> { time_bucket('1 minute', value: 'max(performance)') }
  # scope :worst_response_time_last_hour, -> { time_bucket('1 hour', value: 'max(performance)') }
  # scope :best_response_time_last_hour, -> { time_bucket('1 hour', value: 'min(performance)') }
  # scope :paths, -> { distinct.pluck(:path) }
  # scope :time_bucket, -> (time_dimension, value: 'count(1)') {
  #   select(<<~SQL)
  #     time_bucket('#{time_dimension}', created_at) as time, path,
  #     #{value} as value
  #   SQL
  #    .group('time, path').order('path, time')
  #   }

  # before_save :convert_kwh_to_wh # defined below, but not being used so have this line commented out
  
  # https://www.mattmorgante.com/technology/csv
  # and https://gorails.com/episodes/intro-to-importing-from-csv ~2015
  require 'csv'
   
  def self.import_enphase(file)
    enphase_counter = 0
    puts "#{__LINE__}.#{enphase_counter += 1}. file: #{file}. No file to left means file selection not working!" # empty
    # file shouldn't be hard wired, file should be the first variable below
    
    # From bp, but the following was in the controller where params has a meaning.         
    # file_to_import = params[:energy][:file ].tempfile.path
    # puts "#{__LINE__}. tempfile_path: #{tempfile_path}"
    # 
    # created file_to_import so could put on notice and to keep separate from file which isn't working
    file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/Enphase Monthly Reports/all_enphase_for.2023.csv" # easier if have to destroy db
    
    # CSV.foreach(file_to_import, headers: false) do |row|
    CSV.foreach(file_to_import, headers: true, header_converters: :symbol) do |row|
      puts "#{__LINE__}.#{enphase_counter += 1}. row: #{row}. row.class: #{row.class}" # the row, no quotes
      # puts "10. row.class: #{row.class}" # CSV::Row
      # enphase_hash = row.to_hash
      # puts "#{__LINE__}.#{enphase_counter += 1}. row.to_hash #{enphase_hash}" # 21. row.to_hash {:datetime=>"2023-12-31 12:45:00 -0800", :enphase=>"184"}.
      # # datetime = enphase_hash.fetch["datetime"]
      # enphase = row.to_hash.fetch['enphase']
      datetime = row.to_s.match(/^[^,]+/)[0]
      enphase = row.to_s.match(/[^,]+$/)[0]  # row.to_s.slice(52..55) have to use RegEx as placement data will vary in length
      puts "#{__LINE__}.#{enphase_counter += 1}. datetime: #{datetime}. enphase: #{enphase}"
       # Need to strip the -0800 or whatever ? maybe
      
      upsert({ datetime: datetime, enphase: enphase }, unique_by: :datetime)
    end
  end # def self.import_enphase(file)  
    
  def self.import_edison(file)
    flag = "Not a data line" # persists if defined here. Will be Not yet until hits first local heading. Could be "", but helps a bit to have a value for debugging
    data_line = "Not data"
  
    puts "#{__LINE__}. file: #{file}. No file to left means file selection not working!" # empty
      # file shouldn't be hard wired, file should be the first variable below
      # created file_to_import so could put on notice and to keep separate from file which isn't working
      # Energy_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/01 Dec 23 to 01 Jan 24.Received added to right.csv"
      # sce_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/01 Dec 23 to 01 Jan 24.original LibreOffice.csv"
      # sce_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/LibreOffice.test_short.2023.11.csv"
      sce_file_to_import = "/Users/gscar/Documents/Delicias/Utilities, Energy and Solar/Solar Panels 2023-ABC/Solar production, etc/SCE Reports/SCE Usage 8000435536 Dec 2022 to Dec 2023.withoutHeadersAndQuotes.csv"
      
      # From bp, but the following was in the controller where params has a meaning.
      # file_to_import = params[:energy][:file ].tempfile.path 
      # puts "#{__LINE__}. tempfile_path: #{tempfile_path}"
      
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
        
        # determine datetime and second_col if a data line.
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
    puts "#{__LINE__}. tempfile_path: #{tempfile_path}"
    puts "#{__LINE__}. Date.today.prev_month(months = 2).beginning_of_month: #{Date.today.prev_month(months = 2).beginning_of_month}\n
    Date.today.last_month.beginning_of_month: #{Date.today.last_month.beginning_of_month}"
  end # def self.import_edison(file)
  
  private
  
  # No using this. Well didn't work at some point (it did earlier), but it's now in the data parsing
  # https://russt.me/2018/06/saving-calculated-fields-in-ruby-on-rails-5/
  def convert_kwh_to_wh
    self.from_sce = from_sce * 1000 if from_sce.present?
    self.to_sce =   to_sce * 1000 if to_sce.present?
  end
end
