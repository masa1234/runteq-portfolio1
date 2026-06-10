class CertificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :redirect_to_dashboard_if_registered, only: [:new, :create]
  before_action :set_certification, only: [:show, :edit, :update]

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
    @recent_logs = @certification.study_logs.order(logged_on: :desc).limit(3)
  end

  def edit
  end

  def update
    if @certification.update(certification_params)
      redirect_to @certification, notice: "資格情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_certification
    @certification = current_user.certifications.find(params[:id])
  end

  def certification_params
    params.require(:certification).permit(:name, :exam_date, :target_minutes)
  end

  def redirect_to_dashboard_if_registered
    certification = current_user.certifications.first
    redirect_to certification, notice: "資格はすでに登録されています" if certification
  end
end
