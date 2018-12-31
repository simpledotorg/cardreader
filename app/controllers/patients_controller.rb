class PatientsController < ApplicationController
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
      if @patient.update(patient_with_parsed_medical_history)
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

  def sync_to_server
    return redirect_back(fallback_location: root_path) unless @patient.unsynced?

    host = ENV.fetch('SIMPLE_SERVER_HOST')
    user_id = ENV.fetch('SIMPLE_SERVER_USER_ID')
    access_token = ENV.fetch('SIMPLE_SERVER_ACCESS_TOKEN')

    patients_to_sync = [@patient]
    visits_to_sync = @patient.visits.accept(&:unsynced?)

    sync_service = SyncService.new(host, user_id, access_token, @facility)
    sync_service.sync('patients', patients_to_sync, SyncPatientPayload, report_errors_on_class: Patient)
    sync_service.sync('blood_pressures', visits_to_sync, SyncBloodPressurePayload, report_errors_on_class: Visit)
    sync_service.sync('medical_histories', patients_to_sync, SyncMedicalHistoryPayload, report_errors_on_class: Patient)
    sync_service.sync('appointments', patients_to_sync, SyncAppointmentPayload, report_errors_on_class: Visit)
    sync_service.sync('prescription_drugs', patients_to_sync, SyncPrescriptionDrugPayload)

    redirect_back(fallback_location: root_path)
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
