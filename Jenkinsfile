pipeline {
  agent {
    node {
      label 'master'
      customWorkspace "E:\\Jenkins\\TargetVectorWorkspace"//use backward slashes to avoid problems with how Windows uses directories!!
    }
  }//^all this is necessary to run the build in a special workspace.
  environment {
    ue5Path = "C:\\dev\\UE_5.0\\Engine\\Binaries\\Win64"
    ue5Project = "TargetVector"
    ueProjectFileName = "${ue5Project}.uproject"
    testSuiteToRun = "TargetVector."//the '.' is used to run all tests inside the prettyname. The automation system searches for everything that has 'Game.' in it, so otherGame.'s tests would run too...
    testReportFolder = "TestsReport"
    testsLogName = "RunTests.log"
    pathToTestsLog = "${env.WORKSPACE}" + "\\TestLogs\\" + "${testsLogName}"
    codeCoverageReportName="CodeCoverageReport.xml"
  }
  stages {
    stage('Building') {
      steps {
        echo 'Build Stage Started.'
        // echo 'sending notification to Slack.'
        // slackSend channel: '#builds', 
        //  color: '#4A90E2',
        //  message: "Commit ${GIT_COMMIT} started build ${env.BUILD_NUMBER} on ${env.BRANCH_NAME} at node ${env.NODE_NAME}..."

        bat "BuildWithoutCooking.bat \"${ue5Path}\" \"${env.WORKSPACE}\" \"${ueProjectFilename}\""//builds our project
      }
      post {
        success {
          echo 'Build Stage Successful.'
        }
        failure {
          echo 'Build Stage Unsuccessful.'
        }
      }
    }

    stage('Testing') {
      steps {
        echo 'Testing Stage Started.'
        script {
          if(env.BRANCH_NAME == 'master') {
            echo 'Push to master recognized. Starting tests and code coverage.'
            bat "TestRunnerAndCodeCoverage.bat \"${ue5Path}\" \"${env.WORKSPACE}\" \"${ueProjectFilename}\" \"${testSuiteToRun}\" \"${testReportFolder}\" \"${testsLogName}\" \"${codeCoverageReportName}\""//runs the tests and performs code coverage
          }
          else {
            bat "TestRunner.bat \"${ue5Path}\" \"${env.WORKSPACE}\" \"${ueProjectFilename}\" \"${testSuiteToRun}\" \"${testReportFolder}\" \"${testsLogName}\""//runs the tests
          }
        }
      }
      post {
        success {
          echo 'Testing Stage Successful.'
        }
        failure {
          echo 'Testing Stage Unsuccessful.'
        }
      }
    }



  }
  post {
    always{
      echo 'Tests finished, printing log.'
      bat "type ${pathToTestsLog}"
      echo 'Formatting TestsReport from JSon to JUnit XML'
      formatUnitTests()

        // slackSend channel: "#builds",
        //   color: '#c2f2d0',
        //   message: "_build ${env.BUILD_NUMBER} on ${env.BRANCH_NAME}_\n *Tests Report Summary* - Total Tests: ${testReportSummary.totalCount}, Failures: ${testReportSummary.failCount}, Skipped: ${testReportSummary.skipCount}, Passed: ${testReportSummary.passCount}"
      
      script {
      if (env.BRANCH_NAME == 'master') {
          echo "Publish Code Coverage Report."
          cobertura(coberturaReportFile:"${codeCoverageReportName}")
          }
      }

      echo 'Cleaning up workspace:'
      echo '-checking current workspace.'
      powershell label: 'show workspace', script: 'dir $WORKSPACE'
      bat 'git reset --hard'//resets to HEAD, to the commit in the cloned repository.
      bat 'git clean -dffx .'//removes untracked files.
      echo '-checking clean workspace.'
      powershell label: 'show workspace', script: 'dir $WORKSPACE'

      // echo 'Sending build status notification to Slack:'
    }
    success{
    	echo 'Build Successful.'
    	// discordSend description: "Jenkins Pipeline Build", footer: "Footer Text", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "Webhook URL"
        // slackSend channel: '#builds',
        //   color: 'good', 
        //   message: "*${currentBuild.currentResult}:* Build ${env.BUILD_NUMBER} on ${env.BRANCH_NAME} has *succeded!* :innocent:"
    }
    unstable{
    	echo 'Build Unstable.'
    	// discordSend description: "Jenkins Pipeline Build", footer: "Footer Text", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "Webhook URL"
        // slackSend channel: '#builds',
        //   color: '#E2A52E', 
        //   message: "*${currentBuild.currentResult}:* Build ${env.BUILD_NUMBER} on ${env.BRANCH_NAME} it's *unstable!* :grimacing:"
    }
    failure{
    	echo 'Build Failed.'
    	// discordSend description: "Jenkins Pipeline Build", footer: "Footer Text", link: env.BUILD_URL, result: currentBuild.currentResult, title: JOB_NAME, webhookURL: "Webhook URL"
        // slackSend channel: '#builds',
        //   color: 'danger', 
        //   message: "*${currentBuild.currentResult}:* Build ${env.BUILD_NUMBER} on ${env.BRANCH_NAME} has *failed* :astonished:"
    }
  }
}

import groovy.json.JsonSlurper
import groovy.xml.MarkupBuilder

def testReportSummary = 'to be populated...'

def formatUnitTests() {
        try {
          convertTestsReport()
          testReportSummary = junit "${testReportFolder}\\junit.xml"
        }
        catch (Exception e){
          echo "couldn't generate JUnit Test Report..."
        }
}

def convertTestsReport() {
    def jsonReport = readFile file: "${testReportFolder}\\index.json", encoding: "UTF-8"
    // Needed because the JSON is encoded in UTF-8 with BOM

    jsonReport = jsonReport.replace( "\uFEFF", "" );

    def xmlContent = transformReport( jsonReport )

    writeFile file: "${testReportFolder}\\junit.xml", text: xmlContent.toString()
}

@NonCPS//atomic method
def transformReport( String jsonContent ) {

    def parsedReport = new JsonSlurper().parseText( jsonContent )
    
    def jUnitReport = new StringWriter()
    def builder = new MarkupBuilder( jUnitReport )

    builder.doubleQuotes = true
    builder.mkp.xmlDeclaration version: "1.0", encoding: "utf-8"

    builder.testsuite( tests: parsedReport.succeeded + parsedReport.failed, failures: parsedReport.failed, time: parsedReport.totalDuration ) {
      for ( test in parsedReport.tests ) {
        builder.testcase( name: test.testDisplayName, classname: test.fullTestPath, status: test.state ) {
          if(test.state == "Fail") {
            for ( entry in test.entries ) { 
              if(entry.event.type == "Error") {
                builder.failure( message: entry.event.message, type: entry.event.type, entry.filename + " " + entry.lineNumber )
              }
            }
          }
        }
      }
    } 

    return jUnitReport.toString()
}