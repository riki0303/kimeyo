class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?

  def after_sign_in_path_for(resource)
    if (token = session.delete(:invitation_token))
      handle_invitation_after_auth(token, resource)
    else
      groups_path
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def handle_invitation_after_auth(token, user)
    invitation = GroupInvitation.find_by(token: token)
    if invitation&.valid_invitation?
      # TODO: 例外をハンドリングするか例外を発生させないようにする
      invitation.accept!(user)
      flash[:notice] = 'グループに参加しました'
      group_path(invitation.group)
    else
      flash[:alert] = '招待リンクが無効または期限切れです'
      root_path
    end
  end

  def user_not_authorized
    flash[:alert] = 'この操作を実行する権限がありません。'
    redirect_to(request.referer || root_path)
  end
end
