# frozen_string_literal: true

class UnsubscribedHistory < ActiveRecord::Base
  self.table_name = 'list_unsubscribed'
  db_magic :connection => :gs_schooldb

  belongs_to :user, foreign_key: 'member_id'
end
