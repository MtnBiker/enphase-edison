class DayByDaysController < ApplicationController
  @view_day_by_day = DayByDay.all
  
  def index
    # @day_by_days = day_by_day.all
     if params[:query].present?
       @pagy, @day_by_days = pagy((day_by_day.search_day_by_days(params[:query])))
     else
       @pagy, @day_by_days = pagy((day_by_day.all))
     end
  end
  
  private
      # Use callbacks to share common setup or constraints between actions.
      def set_day_by_day
        @day_by_day = day_by_day.find(params[:id])
      end
  
      # Only allow a list of trusted parameters through.
      def day_by_day_params
        params.require(:day_by_day).permit(:datetime, :enphase, :from_sce, :to_sce)
      end
  end


end
