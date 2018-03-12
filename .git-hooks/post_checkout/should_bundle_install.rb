module Overcommit::Hook::PostCheckout
  class ShouldBundleInstall < ::Overcommit::Hook::Base
    def run
      warning = nil

      if applicable_files.any? { |f| f['Gemfile.lock'] }
        warning = "*** You need to bundle install, because Gemfile.lock changed ***"
      end

      if warning
        return [:warn, warning]
      else
        return :pass
      end
    end
  end
end
