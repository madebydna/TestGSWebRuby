class Admin::ReviewNotesController < ApplicationController

  def create
    note = ReviewNote.new(review_note_params)
    if note.save
      flash_notice 'Note saved'
    else
      flash_error 'Sorry, something went wrong when saving the note'
    end

    redirect_back
  end

  def review_note_params
    params.require(:review_note).permit(:review_id, :notes)
  end

  def review
    Review.find(params[:review_id])
  end


end