class PatientsController < ApplicationController
  include SimpleServerSyncable

  before_action :set_district
  before_action :set_facility
  before_action :set_patient, only: [:show, :edit, :update, :destroy]

  def index
    authorize Patient
    @patients = @facility.patients
  end

  def show
  end

  def new
    @patient = @facility.patients.build(author: current_user)
    authorize @patient
  end

  def edit
  end

  def create
    @patient = @facility.patients.new(patient_with_parsed_medical_history.merge(author: current_user))
    authorize @patient

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
      if @patient.update(patient_with_parsed_medical_history.merge(author: current_user))
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

  def sync
    @patient = Patient.find(params[:patient_id])
    authorize @patient

    return redirect_back(fallback_location: root_path, alert: 'Can only sync unsynced patients!') unless @patient.syncable?

    begin
      sync_patients_for_facility([@patient], @facility)
      redirect_back(fallback_location: root_path, notice: 'Patient synced successfully')
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
      @facility = Facility.find(params[:facility_id])
      authorize @facility, :show?
    end

    def set_patient
      @patient = Patient.find(params[:id])
      authorize @patient
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def patient_params
      params.require(:patient).permit(
        :treatment_number,
        :registered_on,
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
        :heart_attack_in_last_3_years,
        :prior_stroke,
        :chronic_kidney_disease,
        :diagnosed_with_hypertension,
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

  def parse_boolean(value)
    case value.strip
    when Set['Yes']
      true
    when Set['No']
      false
    when Set[nil, '']
      nil
    end
  end

  def patient_with_parsed_medical_history
    medical_history_keys = [:prior_heart_attack, :heart_attack_in_last_3_years, :prior_stroke, :chronic_kidney_disease]
    patient_params.merge(patient_params.to_h.slice(*medical_history_keys).map do |k, v|
      [k, parse_boolean(v)]
    end)
  end
end
