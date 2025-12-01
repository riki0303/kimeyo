class ProposalsController < ApplicationController
  before_action :authenticate_user!

  def index
    @group = current_user.groups.find(params[:group_id])
    authorize Proposal.new(group: @group)
    @proposals = policy_scope(Proposal).preload(:user).order(created_at: :desc)
  end

  def show
    @group = current_user.groups.find(params[:group_id])
    @proposal = @group.proposals.find(params[:id])
    authorize @proposal
  end

  def new
    @group = current_user.groups.find(params[:group_id])
    @proposal = @group.proposals.build
    authorize @proposal
  end

  def create
    @group = current_user.groups.find(params[:group_id])
    @proposal = @group.proposals.build(proposal_params.merge(user: current_user))
    authorize @proposal

    if @proposal.save
      redirect_to group_proposal_path(@group, @proposal), notice: '提案が作成されました。'
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
    @group = current_user.groups.find(params[:group_id])
    @proposal = @group.proposals.find(params[:id])
    authorize @proposal
  end

  def update
    @group = current_user.groups.find(params[:group_id])
    @proposal = @group.proposals.find(params[:id])
    authorize @proposal

    if @proposal.update(proposal_params)
      redirect_to group_proposal_path(@group, @proposal), notice: '提案が更新されました。'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @group = current_user.groups.find(params[:group_id])
    @proposal = @group.proposals.find(params[:id])

    authorize @proposal
    if @proposal.destroy
      redirect_to group_proposals_path(@group), notice: '提案が削除されました。'
    else
      redirect_to group_proposals_path(@group), alert: '提案の削除に失敗しました。'
    end
  end

  private

  def proposal_params
    params.require(:proposal).permit(:title, :content)
  end
end

