class VotesController < ApplicationController
  before_action :authenticate_user!

  def create
    @proposal = Proposal.find(params[:proposal_id])
    @group = @proposal.group
    @vote = @proposal.votes.build(vote_params.merge(user: current_user))
    authorize @vote

    # TODO: トランザクション内でデータ更新する
    if @vote.save
      @proposal.update_status_by_votes!
      redirect_to group_proposal_path(@group, @proposal), notice: '投票しました。'
    else
      redirect_to group_proposal_path(@group, @proposal), alert: '投票に失敗しました。'
    end
  end

  private

  def vote_params
    params.require(:vote).permit(:status)
  end
end
