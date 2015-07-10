# This script is intended to be used as pre-commit hook.
# It rejects commits that include require 'pry' and binding.pry calls; even if commented!

module CommitHooks
  class RejectPry

    PRY_STATEMENTS = [/require\s*'pry'/, /binding\.pry/]

    def reject_commit?
      changeset = CommitHooks::Changeset.new
      PRY_STATEMENTS.each do |statement|
        if changeset.added_lines.any? { |line| statement.match(line) }
          yield error_message
        end
      end
    end

    protected

    def error_message
      [
        'You have checked in a pry statement.',
        'You need to change your commit before adding this changeset.'
      ].join("\n")
    end
  end
end
