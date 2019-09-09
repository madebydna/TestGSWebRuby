rspecSeed = Math.abs(new Random().nextInt() % 1000) + 1
int groups = 2

def checkoutCode() {
    checkout scm
    // checkout([$class: 'GitSCM', poll: true, branches: [[name: '*/jenkins']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'ffcc2432-1458-4cfa-a9f3-a1fc92f27349', url: 'git@githost.greatschools.org:GSWebRuby']]])
}

def buildHasntFailed() {
    return (currentBuild.result == null || (currentBuild.result.toString != 'UNSTABLE' && currentBuild.result.toString != 'FAILURE'))
}

def alreadyWorkedOnThisBuild() {
    sh 'mkdir -p tmp'
    if(fileExists("tmp/build_${BUILD_NUMBER}")) {
      return true
    } else {
      writeFile(file: "tmp/build_${BUILD_NUMBER}", text: "this slave worked on this build")
      return false
    }
}

def prepareWorkspace() {
    if(!alreadyWorkedOnThisBuild()) {
      // This node hasn't worked on this build for this job yet
      // we care because we can do less work if we know we have already cleaned the db etc

      checkoutCode()

      sh 'rm -rf tmp/*'
      sh '''
              mysqldump -hdev.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases gs_schooldb localized_profiles us_geo community api _ak _al _ar _az _ca _co _ct _dc _de _fl _ga _hi _ia _id _il _in _ks _ky _la _ma _md _me _mi _mn _mo _ms _mt _nc _nd _ne _nh _nj _nm _nv _ny _oh _ok _or _pa _ri _sc _sd _tn _tx _ut _va _vt _wa _wi _wv _wy | sed \'s/\\(.*DATABASE.*\\)`\\(.*\\)`/\\1`\\2_test`/;s/\\(.*USE \\)`\\(.*\\)`/\\1`\\2_test`/\' | mysql -f -uroot
              mysqldump -hdev-gsdata.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases gsdata omni| sed \'s/\\(.*DATABASE.*\\)`\\(.*\\)`/\\1`\\2_test`/;s/\\(.*USE \\)`\\(.*\\)`/\\1`\\2_test`/\' | mysql -f -uroot
      '''
    }
}

def buildAssets() {
  sh 'mkdir -p app/assets/webpack'
  sh 'rm -f app/assets/webpack/*'
  sh 'npm install'
  sh 'npm run build:production'
}

def cleanDatabase() {
    sh "mysqldump -hdev.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases gs_schooldb localized_profiles us_geo community api _ak _al _ar _az _ca _co _ct _dc _de _fl _ga _hi _ia _id _il _in _ks _ky _la _ma _md _me _mi _mn _mo _ms _mt _nc _nd _ne _nh _nj _nm _nv _ny _oh _ok _or _pa _ri _sc _sd _tn _tx _ut _va _vt _wa _wi _wv _wy | sed \'s/\\(.*DATABASE.*\\)`\\(.*\\)`/\\1`\\2_test`/;s/\\(.*USE \\)`\\(.*\\)`/\\1`\\2_test`/\' | mysql -f -uroot"
    sh "mysqldump -hdev-gsdata.greatschools.org -d -u${DB_USER} -p${DB_PASS} --databases gsdata omni| sed \'s/\\(.*DATABASE.*\\)`\\(.*\\)`/\\1`\\2_test`/;s/\\(.*USE \\)`\\(.*\\)`/\\1`\\2_test`/\' | mysql -f -uroot"
}

def reportOnAssetSizes() {
    sh 'mkdir -p tmp'
    sh 'script/ci/asset_sizes.rb > tmp/asset_sizes'
    archiveArtifacts allowEmptyArchive: true, artifacts: 'tmp/asset_sizes'
    sh 'rm -f tmp/asset_sizes'
    
    try {
        copyArtifacts filter: 'tmp/asset_sizes', projectName: "$JOB_NAME", selector: lastCompleted()
        sh 'mv tmp/asset_sizes tmp/previous_asset_sizes'
        def msg = sh script: 'cat tmp/previous_asset_sizes | script/ci/asset_sizes.rb', returnStdout: true
        if(msg.trim().length() > 0) {
            slackSend (color: '#00FF00', message: msg.trim())
        }
    } catch(err) {
        echo err.message
    }
}

def compareToPreviousBuild(fileContainingNumber, calculatePercentage, threshold) {
    archiveArtifacts allowEmptyArchive: true, artifacts: fileContainingNumber
    sh "mv ${fileContainingNumber} ${fileContainingNumber}_new"
    
    try {
        copyArtifacts filter: fileContainingNumber, projectName: "$JOB_NAME", selector: lastCompleted()
        sh "mv ${fileContainingNumber} ${fileContainingNumber}_last"
        sh "mv ${fileContainingNumber}_new ${fileContainingNumber}"
        
        def lastNum = readFile("${fileContainingNumber}_last").trim()
        def currentNum = readFile(fileContainingNumber).trim()
        def msg = sh returnStdout: true, script:"script/ci/compare_numbers.rb $lastNum $currentNum $threshold $calculatePercentage"
        return msg.trim()
    } catch(err) {
        echo err.message
        return ''
    }
}

def reportRubocopOffenses() {
    sh 'bundle exec rubocop --fail-level fatal --format simple | tail -n1 | ruby -e "puts STDIN.read.match(/(\\d+) offenses/)[1]" > tmp/num_rubocop_offenses'
    def msg = compareToPreviousBuild('tmp/num_rubocop_offenses', false, 0)
    if(msg.length() > 0) {
        echo "Rubocop offenses ${msg}"
    }
}

def makeBranch(branchNum, groups) {
    { ->
        node('slave') {
            prepareWorkspace()
            sh 'script/ci/bundle_install.sh'
            unstash 'assets'
            try {
                sh "rm -f tmp/rspec-${branchNum}.xml"
                sh "$WORKSPACE/script/ci/run_unit_specs.sh --out tmp/rspec-${branchNum}.xml --seed $rspecSeed `$WORKSPACE/script/ci/unit_rspec_group.rb $groups $branchNum`"
            } catch(err) {
                echo err.message
                if (currentBuild.result == 'UNSTABLE') {
                    currentBuild.result = 'FAILURE'
                    throw err
                }
            } finally {
                stash includes: 'tmp/rspec*.xml', name: "rspec${branchNum}"
                sh 'rm -f tmp/rspec*.xml'
            }
        }
    }
}

def makeJSBranch(branchNum, groups) {
    { ->
        node('slave') {
            prepareWorkspace()
            sh 'script/ci/bundle_install.sh'
            unstash 'assets'
            try {
                retry(3) {
                    timeout(time:30, unit:'MINUTES') {
                        sh "rm -f tmp/features_rspec-${branchNum}.xml"
                        sh 'killall -9 ruby || true'
                        sh "$WORKSPACE/script/ci/run_feature_specs.sh --out tmp/features_rspec-${branchNum}.xml --seed $rspecSeed `$WORKSPACE/script/ci/feature_rspec_group.rb $groups $branchNum`"
                    }
                }
            } catch(err) {
                echo err.message
                if (currentBuild.result == 'UNSTABLE') {
                    currentBuild.result = 'FAILURE'
                    throw err
                }
            } finally {
                stash includes: 'tmp/features_rspec*.xml', name: "features_rspec${branchNum}"
                sh 'rm -f tmp/features_rspec*.xml'
            }
        }
    }
}

def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}

// START

node('slave') {
  prepareWorkspace()
  buildAssets()
  reportOnAssetSizes()
  stash includes: 'app/assets/webpack/*', name: 'assets'
}

stage "Test"

def parallelTests = [1,2].collectEntries([:]) { ["_specs${it}", makeBranch(it, groups)] }
//parallelTests += [1,2].collectEntries([:]) { ["featurespecs${it}", makeJSBranch(it, groups)] }
parallelTests['failFast'] = true
parallel parallelTests

// node('slave') {
//     prepareWorkspace()
//     sh 'script/ci/run_js_unit_tests.sh'
//     stash includes: 'tmp/js_tests_results.xml', name: "js_test_results"
// }

parallel test_report: {
    node('slave') {
        prepareWorkspace()
        for (int j = 1; j <= groups; j++) {
            unstash "rspec${j}"
            //unstash "features_rspec${j}"
        }
        // unstash "js_test_results"
        step([$class: 'JUnitResultArchiver', testResults: 'tmp/*.xml'])
    }
}, rubocop: {
    node('slave') {
        prepareWorkspace()
        reportRubocopOffenses()
    }
}

node('slave') {
  if (currentBuild.result == null) {
      currentBuild.result = 'SUCCESS';
  }

  if (currentBuild.getPreviousBuild() == null || currentBuild.result != currentBuild.getPreviousBuild().result) {
    notifyBuild(currentBuild.result)
  }
  step([$class: 'Mailer',
         notifyEveryUnstableBuild: true,
         recipients: "programmers@greatschools.org",
         sendToIndividuals: false])
 }
