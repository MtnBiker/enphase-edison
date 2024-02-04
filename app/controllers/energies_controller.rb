class EnergiesController < ApplicationController
  # before_action :set_energy, only: %i[ show edit update destroy ]
  
  def self.strip_date(array)
    day_one_no_date = []
    puts "energies_controller.rb:#{__LINE__}. now in strip_date"
    # day_one_array.each item [0]: <%  array.each { |item| day_one_no_date <<  item [0]  } %>
  end
    
  # hourly_graph
  def process_date
    # @the_date_str = params[:the_date]
    @the_date = Date.parse(params[:the_date])
    render turbo_stream: turbo_stream.replace('graph', partial: 'energies/graphs/hourly_graph', locals: { the_date: @the_date })
  end
  
  # Overlay chart
  def date_one
    @date_one_str = params[:date_one]
    @date_one = Date.parse(@date_one_str)
    render turbo_stream: turbo_stream.replace('hour-by-hour-graph', partial: 'energies/graphs/hourly_day_vs_day', locals: { date_one: @date_one })
  end
  
  def date_two
    @date_two_str = params[:date_two]
    @date_two = Date.parse(@date_two_str)
    render turbo_stream: turbo_stream.replace('hour-by-hour-graph', partial: 'energies/graphs/hourly_day_vs_day', locals: { date_two: @date_two })
  end
  
  def increment_date
    puts "energy_controller.rb.#{__LINE__}. More to come" 
    # Is :the_date available? If so:
    @the_date_str = params[:the_date]
    puts "energy_controller.rb.#{__LINE__}. @the_date_str: #{@the_date_str}" 

    @the_date = Date.parse(@the_date_str) + 1.day
    render turbo_stream: turbo_stream.replace('graph', partial: 'energies/graphs/hourly_graph', locals: { the_date: @the_date })
  end
  
  def decrement_date
  end
  
  def index
  end
  
  def hourly
    @hours = Hour.all # DayByDay is using day_by_day from day_by_day.rb model
    render :hourly # overriding routes. But why can't I use routes
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((Hour.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((Hour.all))
     end
  end
  
  def daily
    @days = Day.all
    render :daily # overriding routes. But why can't I use routes
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((Day.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((Day.all))
     end
  end
  
  def monthly
    @months = Month.all
    render :monthly # overriding routes. But why can't I use routes
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((Month.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((Month.all))
     end
  end

  # All logic here, none in model
  def import_enphase
    file_to_import = (params[:file_to_import])
    enphase_counter = 0
    puts "#{__LINE__}.#{enphase_counter += 1}. file_to_import: #{file_to_import}. No file to left means file selection not working!"
    CSV.foreach(file_to_import, headers: true, header_converters: :symbol) do |row|
      datetime = row.to_s.match(/^[^,]+/)[0]
      enphase = row.to_s.match(/[^,]+$/)[0]
      Energy.upsert({ datetime: datetime, enphase: enphase }, unique_by: :datetime)
    end
    redirect_to root_url, notice: "Enphase data imported." # #{file_to_import} not available
  end
  
  def import_edison
    file_to_import = (params[:file_to_import])
    flag = "Not a data line" # persists if defined here. Will be Not yet until hits first local heading. Could be "", but helps a bit to have a value for debugging
    data_line = "Not data"
    
    counter = 0
    row_slice_previous = "Haven't found a data row yet"
   
    CSV.foreach(file_to_import, headers: false) do |row|
      flag = "Delivered" if row[0].match(/Delivered/)
      flag = "Received" if row.flatten.to_s.match(/Received/) # If Received in header won't import with this logic
      
      if row.flatten.to_s.match(/\"202/)  # Unique to data lines. Good through decade. Works for original export, but not Numbers modified and exported because of double quotes being stripped
        data_line = "Data"
      else
        data_line = "Not data"
      end
      
      # determine datetime and second_col if a data line.
      if data_line          
        # get datetime and second column which will either be from_sce or to_sce
        # Getting first 19 characters and making it a time, which is detecting time zone.
        datetime = row[0].to_s.slice(0..18).to_time
        second_col = row[1]
        # This seems unnecessarily complex but it works and isn't done often
        if second_col.nil?
          puts "#{__LINE__}.#{counter}. second_col.nil?"
        else
          second_col = second_col.gsub(/[^\d.]/, '').to_f
          second_col = second_col*1000
        end
      end
        
      if data_line == "Data" && flag == "Delivered"
        puts "#{__LINE__}.#{counter}. Delivered.  datetime: #{datetime}. from_sce: #{second_col}"
        Energy.upsert({ datetime: datetime, from_sce: second_col }, unique_by: :datetime)  
      elsif data_line == "Data" && flag == "Received"
        datetime = row[0].to_s.slice(0..18).to_time
        Energy.upsert({ datetime: datetime, to_sce: second_col }, unique_by: :datetime)
      end      
    end # CSV.foreach
    redirect_to root_url, notice: "Edison data imported." # #{file_to_import} not available
  end
  

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_energy
      @energy = Energy.find(params[:datetime])
    end

    # Only allow a list of trusted parameters through.
    def energy_params
      params.require(:energy).permit(:datetime, :enphase, :from_sce, :to_sce, :the_date)
    end
end
