require 'spec_helper'

describe UrlUtils do
  describe '.valid_redirect_uri?' do
    subject { UrlUtils.valid_redirect_uri?(uri) }

    # Valid URIs
    {
        'relative' => '/foo/bar/',
        'relative with query params' => '/foo/bar/?redirect=http://www.google.com/',
        'absolute localhost' => 'http://localhost/gsr/login/',
        'absolute localhost with port' => 'http://localhost:3000/gsr/login/',
        'absolute localhost homepage with port' => 'http://localhost:3000',
        'absolute localhost homepage with port and query params' => 'http://localhost:3000?redirect=http://www.google.com/',
        'absolute localhost homepage' => 'http://localhost',
        'absolute localhost homepage with query params' => 'http://localhost?redirect=http://www.google.com/',
        'absolute qa homepage' => 'http://qa.greatschools.org',
        'absolute production homepage' => 'http://www.greatschools.org',
        'absolute production homepage with query params' => 'http://www.greatschools.org?redirect=http://www.google.com/',
        'absolute production browse' => 'http://www.greatschools.org/california/alameda/schools/',
        'absolute production profile' => 'http://www.greatschools.org/california/alameda/1-Alameda-High-School/',
        'absolute production profile with query params' => 'http://www.greatschools.org/california/alameda/1-Alameda-High-School/?redirect=http://www.google.com/',
        'secure absolute production homepage' => 'https://www.greatschools.org',
        'secure absolute production homepage with query params' => 'https://www.greatschools.org?redirect=http://www.google.com/',
        'secure absolute production browse' => 'https://www.greatschools.org/california/alameda/schools/',
        'secure absolute production profile' => 'https://www.greatschools.org/california/alameda/1-Alameda-High-School/',
        'secure absolute production profile with query params' => 'https://www.greatschools.org/california/alameda/1-Alameda-High-School/?redirect=http://www.google.com/',
    }.each do |description, url|
      describe "given a #{description} URL" do
        let (:uri) { url }
        it { is_expected.to be_truthy }
      end
    end

    # Invalid URIs
    {
        'nil' => nil,
        'empty string' => '',
        'secure malicious host masquerading as production' => 'https://www.greatschools.org.malicious.cn/phishing/',
        'malicious host masquerading as production' => 'http://www.greatschools.org.malicious.cn/phishing/',
        'simple third party host' => 'http://www.google.com/',
        'simple third party host no trailing slash' => 'http://www.google.com',
        'secure simple third party host' => 'http://www.google.com/',
        'secure simple third party host no trailing slash' => 'http://www.google.com',
        'malicious host masquerading with question mark' => 'http://malicious.org?www.greatschools.org',
        'malicious host masquerading with ampersand' => 'http://malicious.org&www.greatschools.org',
        'secure malicious host masquerading with question mark' => 'https://malicious.org?www.greatschools.org',
        'secure malicious host masquerading with ampersand' => 'https://malicious.org&www.greatschools.org',
    }.each do |description, url|
      describe "given a #{description} URL" do
        let (:uri) { url }
        it { is_expected.to be_falsey }
      end
    end
  end
end