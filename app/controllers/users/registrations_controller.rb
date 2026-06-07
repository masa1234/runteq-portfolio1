class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(resource)
    # #7 資格登録フォーム実装後は new_certification_path に変更する
    root_path
  end
end
