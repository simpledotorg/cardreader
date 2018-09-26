class PatientsController < ApplicationController
  before_action :set_district
  before_action :set_facility
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  def index
    @patients = @facility.patients
  end

  def show
  end

  def new
    @patient = @facility.patients.build
  end

  def edit
  end

  def create
    @patient = @facility.patients.new(patient_params)

    respond_to do |format|
      if @patient.save
        format.html { redirect_to [@district, @facility, @patient], notice: 'Patient was successfully created.' }
        format.json { render :show, status: :created, location: @patient }
      else
        format.html { render :new }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @patient.update(patient_params)
        format.html { redirect_to [@district, @facility, @patient], notice: 'Patient was successfully updated.' }
        format.json { render :show, status: :ok, location: @patient }
      else
        format.html { render :edit }
        format.json { render json: @patient.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @patient.destroy
    respond_to do |format|
      format.html { redirect_to [@district, @facility], notice: 'Patient was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    def set_district
      @district = District.find(params[:district_id])
    end

    def set_facility
      @facility = Facility.find(params[:facility_id])
    end

    def set_patient
      @patient = Patient.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(
        :treatment_number,
        :registered_on,
        :alternate_id_number,
        :name,
        :gender,
        :age,
        :house_number,
        :street_name,
        :area,
        :village,
        :district,
        :pincode,
        :phone,
        :alternate_phone,
        :already_on_treatment,
        :prior_heart_attack,
        :heard_attack_in_last_3_years,
        :prior_stroke,
        :chronic_kidney_disease,
        :medication1_name,
        :medication1_dose,
        :medication2_name,
        :medication2_dose,
        :medication3_name,
        :medication3_dose,
        :medication4_name,
        :medication4_dose
      )
    end
end
