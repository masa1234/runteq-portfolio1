class CertificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_dashboard_if_registered, only: [:new, :create]

  def new
    @certification = Certification.new
  end

  def create
    @certification = current_user.certifications.new(certification_params)

    if @certification.save
      redirect_to @certification, notice: "資格を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @certification = current_user.certifications.find(params[:id])
    @recent_logs = @certification.study_logs.order(logged_on: :desc).limit(3)
  end

  private

  def certification_params
    params.require(:certification).permit(:name, :exam_date, :target_minutes)
  end

  def redirect_to_dashboard_if_registered
    certification = current_user.certifications.first
    redirect_to certification, notice: "資格はすでに登録されています" if certification
  end
end
