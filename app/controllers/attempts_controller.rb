class AttemptsController < ApplicationController
  def index
    @algorithm_versions = Attempt.distinct.order(:algorithm_version).pluck(:algorithm_version)
    @attempts = Attempt.includes(:challenge, :interpretation).order(created_at: :desc)
    @attempts = @attempts.where(algorithm_version: params[:algorithm_version]) if params[:algorithm_version].present?
  end

  def show
    @attempt = Attempt.includes(:challenge, :interpretation).find(params[:id])
    @interpretation = @attempt.interpretation || @attempt.build_interpretation
  end
end
