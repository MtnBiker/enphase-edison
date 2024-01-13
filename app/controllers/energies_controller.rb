class EnergiesController < ApplicationController
  before_action :set_energy, only: %i[ show edit update destroy ]
  
  def import_enphase
    Energy.import_enphase(params[:file_to_import])
    redirect_to root_url, notice: "Enphase data imported." # #{file_to_import} not available
  end
  
  def import_edison
    Energy.import_edison(params[:file_to_import])
    redirect_to root_url, notice: "Edison data imported." # #{file_to_import} not available
  end

  # GET /energies or /energies.json
  def index
    # @energies = Energy.all
     if params[:query].present?
       @pagy, @energies = pagy((Energy.search_energies(params[:query])))
     else
       @pagy, @energies = pagy((Energy.all))
     end
  end

  # GET /energies/1 or /energies/1.json
  def show
  end

  # GET /energies/new
  def new
    @energy = Energy.new
  end

  # GET /energies/1/edit
  def edit
  end

  # POST /energies or /energies.json
  def create
    @energy = Energy.new(energy_params)

    respond_to do |format|
      if @energy.save
        format.html { redirect_to energy_url(@energy), notice: "Energy was successfully created." }
        format.json { render :show, status: :created, location: @energy }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @energy.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /energies/1 or /energies/1.json
  def update
    respond_to do |format|
      if @energy.update(energy_params)
        format.html { redirect_to energy_url(@energy), notice: "Energy was successfully updated." }
        format.json { render :show, status: :ok, location: @energy }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @energy.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /energies/1 or /energies/1.json
  def destroy
    @energy.destroy!

    respond_to do |format|
      format.html { redirect_to energies_url, notice: "Energy was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_energy
      @energy = Energy.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def energy_params
      params.require(:energy).permit(:datetime, :enphase, :from_sce, :to_sce)
    end
end