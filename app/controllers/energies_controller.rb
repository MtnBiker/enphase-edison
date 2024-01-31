class EnergiesController < ApplicationController
  # before_action :set_energy, only: %i[ show edit update destroy ]
  
  # Unneeded from ChatGPT
  # def pick_date
  #   # @selected_date = Date.current
  #   # # Set an initial value for @the_date
  #   # @the_date = Date.parse('2024-01-01')
  #   # # Set a default value for @the_date if it's not already defined
  #   # @the_date ||= Date.current
  # end
  
  def process_date
    @the_date_str = params[:the_date]
    @the_date = Date.parse(@the_date_str)
    render turbo_stream: turbo_stream.replace('graph', partial: 'energies/graphs/hourly_graph', locals: { the_date: @the_date })
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
  
  # This was for Stimulus which wasn't the way to do what I needed 
  # def process_date
  #   @the_date = params[:the_date]
  #   @the_date = Date.strptime(@the_date, '%Y-%m-%d') # being fed a string and need a date class
  #   # Process the selected_date as needed
  #   puts "energies_controller:#{__LINE__}. @the_date: #{@the_date}. @the_date.class: #{@the_date}.class"
  #   render :_hourly_graph, locals: { theDate: @the_date }
  # end

  # GET /energies or /energies.json
  # Nothing here since have hourly, daily, monthly
  def index
  end
  
  def hourly
    @hour_by_hours = HourByHour.all # DayByDay is using day_by_day from day_by_day.rb model
    render :hourly # overriding routes. But why can't I use routes
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((HourByHour.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((HourByHour.all))
     end
  end
  
  def daily
    @day_by_days = DayByDay.all # DayByDay is using day_by_day from day_by_day.rb model
    render :daily # overriding routes. But why can't I use routes
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((DayByDay.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((DayByDay.all))
     end
  end
  
  # Not working. Again ChatGPT.
  def change_daily_graph
    @the_date = params[:the_date]
    # Other processing logic here
  
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js   # This will render change_daily_graph.js.erb by default
    end
  end
  
  # def change_daily_graph
  #   render partial: "enerties/daily_graph", locals: {the_date: @the_date}
  # end

 def monthly
    @month_by_months = MonthByMonth.all # DayByDay is using day_by_day from day_by_day.rb model
    render :monthly # overriding routes. But why can't I use routes
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((MonthByMonth.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((MonthByMonth.all))
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
