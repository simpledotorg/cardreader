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
    @visit = @patient.visits.build
  end

  def edit
  end

  def create
    @visit = @patient.visits.new(visit_params)

    respond_to do |format|
      if @visit.save
        format.html { redirect_to [@district, @facility, @patient], notice: 'Visit was successfully created.' }
        format.json { render :show, status: :created, location: @visit }
      else
        format.html { render :new }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @visit.update(visit_params)
        format.html { redirect_to [@district, @facility, @patient], notice: 'Visit was successfully updated.' }
        format.json { render :show, status: :ok, location: @visit }
      else
        format.html { render :edit }
        format.json { render json: @visit.errors, status: :unprocessable_entity }
      end
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
end
