class HomeController < ApplicationController
  def index
    return unless user_signed_in?
    certification = current_user.certifications.first
    redirect_to certification ? certification : new_certification_path
  end
end
