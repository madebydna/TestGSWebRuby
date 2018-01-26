# frozen_string_literal: true

class Admin::UpdateQueueController < ApplicationController

  def index
    @done_vs_todo = UpdateQueue.done_vs_todo_per_source
    @failed_within_24_hrs = UpdateQueue.failed_within_24_hrs
    @failed_within_2_weeks = UpdateQueue.failed_within_2_weeks
    @oldest_item_in_todo = UpdateQueue.oldest_item_in_todo
    @created_in_last_week = UpdateQueue.created_in_last_week
    @most_recent_failure_time = UpdateQueue.most_recent_failure.try(:updated)
  end

end
