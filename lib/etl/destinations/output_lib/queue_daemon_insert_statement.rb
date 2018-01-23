# frozen_string_literal: true

class QueueDaemonInsertStatement
  def self.build(source, blob, priority=4)
   "insert into gs_schooldb.update_queue (source,status,priority,update_blob,created,updated) values ('#{source}','todo',#{priority},'#{blob}',NOW(),NOW());\n";
  end
end


