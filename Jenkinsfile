def getRSpecSeed(){
    return Math.abs(new Random().nextInt() % 1000) + 1
}
rspecSeed = getRSpecSeed()

def checkoutCode() {
    checkout([$class: 'GitSCM', poll: true, branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'ffcc2432-1458-4cfa-a9f3-a1fc92f27349', url: 'git@githost.greatschools.org:GSWebRuby']]])
}

def bundleInstall() {
    sh '''
        export PATH="/usr/local/bin:/usr/bin:$PATH"
        export QMAKE=/usr/local/lib/qt5/bin/qmake
        export SPEC=freebsd-clang   # FreeBSD should use clang, not g++
        export CAPYBARA_WEBKIT_INCLUDE_PATH=/usr/local/include
        export CAPYBARA_WEBKIT_LIBS="-L/usr/local/lib/"
        bundle check || bundle install --deployment --without development
        npm install
        npm run build:production
    '''
}

def cleanDatabase() {
    sh '''
        mysqldump -hdev.greatschools.org -d -uservice -pservice \\
        --databases gs_schooldb localized_profiles gscms_pub us_geo community surveys \\
        _ak _al _ar _az _ca _co _ct _dc _de _fl _ga _hi _ia _id _il _in _ks _ky _la \\
        _ma _md _me _mi _mn _mo _ms _mt _nc _nd _ne _nh _nj _nm _nv _ny _oh _ok _or \\
        _pa _ri _sc _sd _tn _tx _ut _va _vt _wa _wi _wv _wy | \\
        sed \'s/\\(.*DATABASE.*\\)`\\(.*\\)`/\\1`\\2_test`/;s/\\(.*USE \\)`\\(.*\\)`/\\1`\\2_test`/\' | mysql -f -uroot
    '''
}

def cleanTmp() {
    sh '''
        if [ ! -d tmp ]
        then
        mkdir tmp
        fi
        rm -rf tmp/*
    '''
}

def runRSpecs(groups, branchNum) {
    echo "my rspec group is ${branchNum}"
    withEnv(["RSPEC_SEED=${rspecSeed}","SPEC_GROUPS=${groups}","SPEC_GROUP=${branchNum}"]) {
        sh '''
        export PATH="/usr/local/bin:/usr/bin:$PATH"

        ln -sf /usr/local/bin/ruby21 bin/ruby
        ln -sf /usr/local/bin/git bin/git
        SPECS_LIST=`ruby -e 'specs=Dir.glob("spec/**/*_spec.rb"); puts specs.reject { |s| s.include?("features/") || s.include?("qa/") }.each_slice(specs.size/ENV["SPEC_GROUPS"].to_i+1).to_a[ENV["SPEC_GROUP"].to_i].join(" ")'`

        RAILS_ENV=test coverage=false bundle exec rspec --seed "$RSPEC_SEED" \\
        --no-color \\
        --tag ~js --tag ~remote --tag ~brittle \\
        --require ./spec/support/failures_html_formatter.rb \\
        --format RSpec::Core::Formatters::FailuresHtmlFormatter --out ./tmp/spec_failures_html_report.html \\
        --format RspecJunitFormatter --out "./tmp/rspec-$SPEC_GROUP.xml" \\
        --failure-exit-code 0 \\
        --deprecation-out ./tmp/rspec_deprecation_warnings.txt $SPECS_LIST
        '''
    }
}

def runJSRSpecs(groups, branchNum) {
    echo "my rspec group is ${branchNum}"
    try {
        sh '''
        killall -9 ruby21
        '''
    } catch(err) {
    }
    withEnv(["RSPEC_SEED=${rspecSeed}","SPEC_GROUPS=${groups}","SPEC_GROUP=${branchNum}"]) {
        sh '''
        export PATH="/usr/local/bin:/usr/bin:$PATH"

        ln -sf /usr/local/bin/ruby21 bin/ruby
        ln -sf /usr/local/bin/git bin/git
        /usr/local/bin/restart_xvfb.sh
        export DISPLAY=:99

        SPECS_LIST=`ruby -e 'specs=Dir.glob("spec/features/**/*_spec.rb"); puts specs.each_slice(specs.size/ENV["SPEC_GROUPS"].to_i+1).to_a[ENV["SPEC_GROUP"].to_i].join(" ")'`

        RAILS_ENV=test coverage=false bundle exec rspec --seed "$RSPEC_SEED" \\
        --no-color \\
        --tag ~remote --tag ~brittle \\
        --require ./spec/support/failures_html_formatter.rb \\
        --format RSpec::Core::Formatters::FailuresHtmlFormatter --out ./tmp/feature_spec_failures_html_report.html \\
        --format RspecJunitFormatter --out ./tmp/features_rspec-$SPEC_GROUP.xml \\
        --failure-exit-code 0 \\
        --deprecation-out ./tmp/rspec_deprecation_warnings.txt $SPECS_LIST
        '''
    }
}


def makeBranch(branches, groups, branchNum) {
    branches["group${branchNum+1}"] = {
        node('slave') {
            checkoutCode()
            cleanTmp()
            bundleInstall()
            cleanDatabase()
            try {
                runRSpecs(groups, branchNum)
            } catch(err) {
                if (currentBuild.result == 'UNSTABLE') {
                    currentBuild.result = 'FAILURE'
                    throw err
                }
            } finally {
                stash includes: 'tmp/*.xml', name: "rspec${branchNum}"
            }
        }
    }
}

def makeJSBranch(branches, groups, branchNum) {
    branches["jsgroup${branchNum+1}"] = {
        node('slave') {
            checkoutCode()
            cleanTmp()
            bundleInstall()
            cleanDatabase()
            try {
                runJSRSpecs(groups, branchNum)
            } catch(err) {
                if (currentBuild.result == 'UNSTABLE') {
                    currentBuild.result = 'FAILURE'
                    throw err
                }
            } finally {
                stash includes: 'tmp/features_rspec*.xml', name: "jsrspec${branchNum}"
            }
        }
    }
}

int groups = 4
def branches = [:]
for (int i = 0; i < groups; i++) {
  makeBranch(branches, groups, i)
}
branches['failFast'] = true
stage "RSpecs"
parallel branches

stage "JS Tests"
node('slave') {
    sh '''
        /usr/local/bin/restart_xvfb.sh
        export DISPLAY=:99
        RAILS_ENV=test bundle exec rake teaspoon FORMATTERS="junit>tmp/js_tests_results.xml"
    '''
    stash includes: 'tmp/js_tests_results.xml', name: "js_test_results"
}

if (currentBuild.result == null || (currentBuild.result.toString != 'UNSTABLE' && currentBuild.result.toString != 'FAILURE')) {
    def jsBranches = [:]
    for (int i = 0; i < groups; i++) {
        makeJSBranch(jsBranches, groups, i)
    }
    jsBranches['failFast'] = true
    stage "JS Specs"
    parallel jsBranches
}

node('slave') {
    for (int j = 0; j < groups; j++) {
        unstash "rspec${j}"
        unstash "jsrspec${j}"
    }
    unstash "js_test_results"
    
    step([$class: 'JUnitResultArchiver', testResults: 'tmp/*.xml'])
    
    if (currentBuild.result == null) {
        currentBuild.result = 'SUCCESS';
    }
                
    step([$class: 'Mailer',
           notifyEveryUnstableBuild: true,
           recipients: "programmers@greatschools.org",
           sendToIndividuals: false])
}
