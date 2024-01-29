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
    puts "energies_controller.rb:#{__LINE__}. @the_date: #{@the_date}. @the_date.class: #{@the_date}.class"
  
    # Process the selected_date as needed
  
    # Assuming you have a method to get the data for the graph
    # Doesn't the graph know whee to get the data
    # @graph_data = fetch_graph_data(@the_date)
  
    # Render a Turbo Stream to update the graph element
    render turbo_stream: turbo_stream.replace('graph', partial: 'energies/hourly_graph', locals: { the_date: @the_date })
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
  
  def import_enphase
    Energy.import_enphase(params[:file_to_import])
    redirect_to root_url, notice: "Enphase data imported." # #{file_to_import} not available
  end
  
  def import_edison
    Energy.import_edison(params[:file_to_import])
    redirect_to root_url, notice: "Edison data imported." # #{file_to_import} not available
  end
  

  private

    def fetch_graph_data(selected_date)
      # Your logic to fetch graph data based on the selected date
      # Return the data in a format that your graphing library understands
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_energy
      @energy = Energy.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def energy_params
      params.require(:energy).permit(:datetime, :enphase, :from_sce, :to_sce, :the_date)
    end
end
