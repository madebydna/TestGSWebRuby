# This script is intended to be used as pre-commit hook.
# It rejects commits that include files that designers don't need to touch.
# See PT-1635 for more information.

module CommitHooks
  class DesignerAccess

    STYLESHEET_DIRECTORY  = 'app/assets/stylesheets/'
    STYLE_GUIDE_DIRECTORY = 'app/views/admin/style_guide/'

    def reject_commit?
      changeset = CommitHooks::Changeset.new
      rejected_files = changeset.changed_files.delete_if do |file|
        file if is_okay_to_edit?(file)
      end
      if rejected_files.size > 0
        yield error_message(rejected_files)
      end
    end

    protected

    def is_okay_to_edit?(file)
      file.include?(STYLE_GUIDE_DIRECTORY) || file.include?(STYLESHEET_DIRECTORY)
    end

    def error_message(files)
      "You do not have permission to commit changes to:\n" <<
      files.join("\n") <<
      "\n\n" <<
      "Please only commit changes to files within these directories:\n" <<
      STYLESHEET_DIRECTORY <<
      "\n" <<
      STYLE_GUIDE_DIRECTORY <<
      "\n"
    end
  end
end
