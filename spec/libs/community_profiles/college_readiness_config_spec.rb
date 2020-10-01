require "spec_helper"

describe MetricsCaching::CollegeReadinessConfig do

    context "POST_SECONDARY" do
        it "is an array" do
            expect(MetricsCaching::CollegeReadinessConfig::POST_SECONDARY).to be_a(Array)
        end

        it "contains a list of defined strings" do
            expect(MetricsCaching::CollegeReadinessConfig::POST_SECONDARY).to match_array([
                'Graduating seniors pursuing other college',
                'Graduating seniors pursuing 4 year college/university',
                'Graduating seniors pursuing 2 year college/university',
                'Percent of students who will attend out-of-state colleges',
                'Percent of students who will attend in-state colleges',
                'Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 16 months after graduation',
                'Percent enrolled in any public in-state postsecondary institution within the immediate fall after graduation',
                'Percent Enrolled in College Immediately Following High School',
                'Percent enrolled in any institution of higher learning in the last 0-16 months',
                'Percent enrolled in a 4-year institution of higher learning in the last 0-16 months',
                'Percent enrolled in a 2-year institution of higher learning in the last 0-16 months',
                'Percent enrolled in any public in-state postsecondary institution within 12 months after graduation',
                'Percent enrolled in any postsecondary institution within 12 months after graduation',
                'Percent enrolled in any 2 year postsecondary institution within 6 months after graduation',
                'Percent enrolled in any 2 year postsecondary institution within the immediate fall after graduation',
                'Percent enrolled in any 2 year public in-state postsecondary institution within the immediate fall after graduation',
                'Percent enrolled in any 4 year postsecondary institution within 6 months after graduation',
                'Percent enrolled in any 4 year postsecondary institution within the immediate fall after graduation',
                'Percent enrolled in any 4 year public in-state postsecondary institution within the immediate fall after graduation',
                'Percent enrolled in any in-state postsecondary institution within 12 months after graduation',
                'Percent enrolled in any in-state postsecondary institution within the immediate fall after graduation',
                'Percent enrolled in any out-of-state postsecondary institution within the immediate fall after graduation',
                'Percent enrolled in any postsecondary institution within 24 months after graduation',
                'Percent enrolled in any postsecondary institution within 6 months after graduation',
                'Percent enrolled in any public in-state postsecondary institution or intended to enroll in any out-of-state institution, or in-state private institution within 12 months after graduation',
                'Percent enrolled in any public in-state institution within 16 months after graduation'
            ])
        end

        it "contains a list of unique strings" do
            expect(MetricsCaching::CollegeReadinessConfig::POST_SECONDARY.uniq.length).to eq(MetricsCaching::CollegeReadinessConfig::POST_SECONDARY.length)
        end
    end

    context "REMEDIATION_SUBGROUPS" do
        it "is an array" do
          expect(MetricsCaching::CollegeReadinessConfig::REMEDIATION_SUBGROUPS).to be_a(Array)
        end

        it "contains a list of defined strings" do
          expect(MetricsCaching::CollegeReadinessConfig::REMEDIATION_SUBGROUPS).to match_array([
            'Percent Needing Remediation for College',
            'Percent Needing any Remediation for College',
            'Graduates needing Reading Remediation for College',
            'Graduates needing Writing Remediation for College',
            'Graduates needing English Remediation for College',
            'Graduates needing Science Remediation for College',
            'Graduates needing Math Remediation for College',
            'Percent needing remediation in in-state public 2-year institutions',
            'Percent needing any remediation in in-state public 2-year institutions',
            'Graduates needing Reading remediation in 2-year college',
            'Graduates needing Math remediation in 2-year college',
            'Graduates needing English remediation in 2-year college',
            'Graduates needing Science remediation in 2-year college',
            'Graduates needing Writing remediation in 2-year college',
            'Percent needing remediation in in-state public 4-year institutions',
            'Percent needing any remediation in in-state public 4-year institutions',
            'Graduates needing Reading remediation in 4-year college',
            'Graduates needing Math remediation in 4-year college',
            'Graduates needing English remediation in 4-year college',
            'Graduates needing Science remediation in 4-year college',
            'Graduates needing Writing remediation in 4-year college'
          ])
        end
    end

    context "SECOND_YEAR" do
        it "is an array" do
            expect(MetricsCaching::CollegeReadinessConfig::SECOND_YEAR).to be_a(Array)
        end

        it "contains a list of defined strings" do
            expect(MetricsCaching::CollegeReadinessConfig::SECOND_YEAR).to match_array([
                'Percent Enrolled in College and Returned for a Second Year',
                'Percent Enrolled in an in-state public 4 year college and Returned for a Second Year',
                'Percent Enrolled in an in-state public 2 year college and Returned for a Second Year'])
        end
    end

end