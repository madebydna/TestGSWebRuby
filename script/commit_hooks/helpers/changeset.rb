module CommitHooks
  class Changeset

    attr_accessor :added_lines, :removed_lines

    def changed_files
      `git diff --cached --name-only`.split("\n")
    end

    def added_lines
      self.added_lines = begin
        remove_leader_and_whitespace_for_lines_that_start_with('+')
      end
    end

    def removed_lines
      self.added_lines = begin
        remove_leader_and_whitespace_for_lines_that_start_with('-')
      end
    end

    def changed_lines_that_start_with(string='')
      `git diff --cached`.split("\n").select do |line|
        line.start_with?(string)
      end
    end

    protected

    def remove_leader_and_whitespace_for_lines_that_start_with(char='')
      char_for_regex = "\\" << char
      changed_lines_that_start_with("#{char} ").map do |line|
        line.sub(/^#{char_for_regex}\s+/, '')
      end
    end
  end
end
