class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    group_ids = current_user.group_ids
    @groups = Group.where(id: group_ids).includes(:members)
  end

  def show
  end

  def new
    @group = current_user.owned_groups.build
  end

  def create
    @group = current_user.owned_groups.build(group_params)

    # TODO: モデルメソッドとして定義
    if @group.save
      # 作成者もメンバーとして追加
      @group.group_memberships.create!(user: current_user)
      redirect_to @group, notice: 'グループが作成されました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(group_params)
      redirect_to @group, notice: 'グループが更新されました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @group.destroy
      redirect_to groups_path, notice: 'グループが削除されました。'
    else
      redirect_to groups_path, alert: 'グループの削除に失敗しました。'
    end
  end

  private

  def set_group
    @group = current_user.groups.find_by(id: params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end

