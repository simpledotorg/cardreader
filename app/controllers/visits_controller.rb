class VisitsController < ApplicationController
  before_action :set_district
  before_action :set_facility
  before_action :set_patient
  before_action :set_visit, only: [:show, :edit, :update, :destroy]

  def index
    @visits = @patient.visits
  end

  def show
  end

  def new
    if params[:prefill_from_previous_visit]
      @visit = @patient.visits.build(previous_visit_details)
    else
      @visit = @patient.visits.build
    end
  end

  def edit
  end

  def create
    @visit = @patient.visits.new(visit_params)

    if @visit.save
      if add_new_after_update?
        redirect_to new_district_facility_patient_visit_url(@district, @facility, @patient), notice: 'Visit was successfully created.'
      else
        redirect_to [@district, @facility, @patient], notice: 'Visit was successfully created.'
      end
    else
      render :new
    end
  end

  def update
    if @visit.update(visit_params)
      if add_new_after_update?
        redirect_to new_district_facility_patient_visit_url(@district, @facility, @patient), notice: 'Visit was successfully updated.'
      else
        redirect_to [@district, @facility, @patient], notice: 'Visit was successfully updated.'
      end
    else
      render :edit
    end
  end

  def destroy
    @visit.destroy
    respond_to do |format|
      format.html { redirect_to [@district, @facility, @patient], notice: 'Visit was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

    def previous_visit_details
      drug_keys = %w(amlodipine telmisartan enalpril chlorthalidone aspirin statin beta_blocker losartan medication1_name medication1_dose medication2_name medication2_dose medication3_name medication3_dose)
      @patient.visits.order(measured_on: :desc).first.attributes.slice(*drug_keys)
    end

    def set_district
      @district = District.find(params[:district_id])
    end

    def set_facility
      @facility = @district.facilities.find(params[:facility_id])
    end

    def set_patient
      @patient = @facility.patients.find(params[:patient_id])
    end

    def set_visit
      @visit = @patient.visits.find(params[:id])
    end

    def visit_params
      params.require(:visit).permit(
        :systolic,
        :diastolic,
        :measured_on,
        :blood_sugar,
        :amlodipine,
        :telmisartan,
        :enalpril,
        :chlorthalidone,
        :aspirin,
        :statin,
        :beta_blocker,
        :losartan,
        :medication1_name,
        :medication1_dose,
        :medication2_name,
        :medication2_dose,
        :medication3_name,
        :medication3_dose,
        :referred_to_specialist,
        :next_visit_on
      )
    end

    def add_new_after_update?
      params[:commit] == "Save and Add New Visit"
    end
end
