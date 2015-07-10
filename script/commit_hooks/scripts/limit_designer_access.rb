require_relative '../commit_hooks'

arbiter = CommitHooks::DesignerAccess.new
arbiter.reject_commit? do |error|
  if error
    puts error
    exit 1
  end
end
