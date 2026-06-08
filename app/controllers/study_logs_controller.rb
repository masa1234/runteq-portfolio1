class StudyLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_certification

  def new
    @study_log = @certification.study_logs.new(logged_on: Date.current)
  end

  def create
    @study_log = @certification.study_logs.new(study_log_params)
    if @study_log.save
      redirect_to @certification, notice: "学習を記録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_certification
    @certification = current_user.certifications.find(params[:certification_id])
  end

  def study_log_params
    params.require(:study_log).permit(:studied_minutes, :logged_on, :memo)
  end
end
