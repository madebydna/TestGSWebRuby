require 'net/sftp'

module ExactTarget
  class ExactTargetSFTP
    def upload(file, remote_location=nil)
      remote_location ||= "Import/"
      Net::SFTP.start(ENV_GLOBAL['exacttarget_host'], ENV_GLOBAL['exacttarget_username'], :password => ENV_GLOBAL['exacttarget_password']) do |sftp|
        # upload a file or directory to the remote host
        sftp.upload!(file, remote_location) if file
      end
    end
    def download(remote_file, local_location=nil)
      local_location ||= "/tmp/"
      Net::SFTP.start(ENV_GLOBAL['exacttarget_host'], ENV_GLOBAL['exacttarget_username'], :password => ENV_GLOBAL['exacttarget_password']) do |sftp|
        # upload a file or directory to the remote host
        sftp.upload!(remote_file, local_location) if remote_file
      end
    end
  end
end