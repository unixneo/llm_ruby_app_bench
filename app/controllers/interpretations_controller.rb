class InterpretationsController < ApplicationController
  def create
    @attempt = Attempt.find(params[:attempt_id])
    @interpretation = @attempt.build_interpretation(interpretation_params)

    if @interpretation.save
      redirect_to @attempt, notice: "Interpretation recorded."
    else
      render "attempts/show", status: :unprocessable_entity
    end
  end

  private

  def interpretation_params
    params.require(:interpretation).permit(:classification, :notes)
  end
end
