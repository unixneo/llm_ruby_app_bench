class AttemptsController < ApplicationController
  def index
    @challenge = challenge_for_scope
    @algorithm_versions = scoped_attempts.distinct.order(:algorithm_version).pluck(:algorithm_version)
    @attempts = scoped_attempts.includes(:challenge, :interpretation).order(created_at: :desc)
    @attempts = @attempts.where(algorithm_version: params[:algorithm_version]) if params[:algorithm_version].present?
  end

  def show
    @attempt = Attempt.includes(:challenge, :interpretation).find(params[:id])
    @challenge = @attempt.challenge
    @interpretation = @attempt.interpretation || @attempt.build_interpretation
  end

  private

  def scoped_attempts
    scope = Attempt.all
    scope = scope.where(challenge: @challenge) if @challenge
    scope
  end

  def challenge_for_scope
    return nil unless params[:challenge_name]

    Challenge.find_by(name: params[:challenge_name])
  end
end
