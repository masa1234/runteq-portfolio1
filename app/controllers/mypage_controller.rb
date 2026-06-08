class MypageController < ApplicationController
  before_action :authenticate_user!

  def index
    @certification = current_user.certifications.first
  end
end
