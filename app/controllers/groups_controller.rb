class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [:show, :edit, :update, :destroy]

  def index
    @groups = policy_scope(Group)
  end

  def show
    authorize @group
  end

  def new
    @group = current_user.owned_groups.build
    authorize @group
  end

  def create
    @group = current_user.owned_groups.build(group_params)
    authorize @group

    if @group.save
      @group.add_owner_as_member
      redirect_to @group, notice: 'グループが作成されました。'
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    authorize @group
  end

  def update
    authorize @group
    if @group.update(group_params)
      redirect_to @group, notice: 'グループが更新されました。'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @group
    if @group.destroy
      redirect_to groups_path, notice: 'グループが削除されました。'
    else
      redirect_to groups_path, alert: 'グループの削除に失敗しました。'
    end
  end

  private

  def set_group
    @group = current_user.groups.find(params[:id])
  end

  def group_params
    params.require(:group).permit(:name)
  end
end

