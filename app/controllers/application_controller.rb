class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_in_path_for(resource)
    if (token = session.delete(:invitation_token))
      handle_invitation_after_auth(token, resource)
    else
      super
    end
  end

  private

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
