class GroupInvitationsController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]
  before_action :set_invitation, only: [ :show ]

  def create
    @group = Group.find(params[:group_id])
    @invitation = @group.group_invitations.build(created_by: current_user)
    authorize @invitation
    if @invitation.save
      redirect_to group_path(@group), notice: '招待リンクを生成しました'
    else
      redirect_to group_path(@group), alert: '招待リンクの生成に失敗しました'
    end
  end

  def show
    if user_signed_in?
      # TODO: 例外のハンドリング処理を書く必要がある。または例外を発生させないようにする
      @invitation.accept!(current_user)
      redirect_to group_path(@invitation.group), notice: 'グループに参加しました'
    else
      session[:invitation_token] = @invitation.token
      redirect_to new_user_session_path, notice: 'グループに参加するにはログインしてください'
    end
  end

  private

  def set_invitation
    @invitation = GroupInvitation.find_by(token: params[:token])
    unless @invitation
      redirect_to root_path, alert: '招待リンクが見つかりません'
      return
    end
    return if @invitation.valid_invitation?

    redirect_to root_path, alert: '招待リンクが無効または期限切れです'
  end
end
