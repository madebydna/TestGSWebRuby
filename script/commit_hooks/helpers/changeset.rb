module CommitHooks
  class Changeset

    def changed_files
      `git diff --cached --name-only`.split("\n")
    end
  end
end
