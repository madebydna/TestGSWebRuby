class ReviewsController < ApplicationController

  include AuthenticationConcerns
  include ReviewHelper

  def new
    @review = Review.new
  end

  def create
    @review = Review.new(params[:review])
    respond_to do |format|
      if @review.save
        format.json { render json: {message: "WOO", buddy: "man"} , status: :created }
      else
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

private

  def review_params
    params.require(:review).permit(:list_member_id,:school_id, :state, :review_question_id, :comment,
    review_answers_attributes:[ :value, :review_id])
  end

end
