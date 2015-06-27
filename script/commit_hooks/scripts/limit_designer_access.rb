require_relative '../commit_hooks'

limiter = CommitHooks::DesignerAccess.new
limiter.reject_commit? do |error|
  if error
    puts error
    exit 1
  end
end
