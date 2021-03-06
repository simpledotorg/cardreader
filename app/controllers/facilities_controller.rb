class FacilitiesController < ApplicationController
  include SimpleServerSyncable

  before_action :set_district
  before_action :set_facility, only: [:show, :edit, :update, :destroy]

  def index
    authorize Facility
    @facilities = Facility.all
    @facility = Facility.new
  end

  def show
    authorize Patient, :index?

    @patients = @facility.patients
    @patient_sync_report = SyncReport.new(@patients.sync_statuses)
  end

  def edit
  end

  def update
    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to @facility, notice: 'Facility was successfully updated.' }
        format.json { render :show, status: :ok, location: @facility }
      else
        format.html { render :edit }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @facility.destroy
    respond_to do |format|
      format.html { redirect_to facilities_url, notice: 'Facility was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def sync
    @facility = Facility.find(params[:facility_id])
    authorize @facility

    begin
      patients = Patient.where(facility: @facility).select(&:syncable?)
      sync_patients_for_facility(patients, @facility)

      redirect_back(fallback_location: root_path, notice: 'Patients for facility synced successfully')
    rescue SyncError => error
      redirect_back(fallback_location: root_path, notice: error.message)
    end
  end

  private
    def set_district
      @district = District.find(params[:district_id])
      authorize @district, :show?
    end

    def set_facility
      @facility = Facility.find(params[:id])
      authorize @facility
    end

    def facility_params
      params.require(:facility).permit(:name)
    end
end
