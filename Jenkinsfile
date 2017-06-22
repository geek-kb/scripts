pipeline {
	agent any
	options { disableConcurrentBuilds() }
	environment {
		channel = "#general"
	}
	stages {
		stage ('Downloading project') {
			steps {
				script {
					try {
						node {
							checkout scm
							sh(returnStdout: true, script: "ls -l").trim()
						}
					} catch (err) {
						currentBuild.result = 'FAILURE'
						slackSend channel: channel, color: 'danger', teamDomain: null, token: null,
						message: "*Failed to build ${env.JOB_NAME}*! :x: (<!here|here>)"
					}
				}
			}	
		}
		stage ('whatever') {
			steps {
				print "Current build result: ${currentBuild.result}"
			}
		}
			
		stage ('results') {
			steps {
				script {
					if (!currentBuild.result) {
						currentBuild.result = 'SUCCESS'
						slackSend channel: channel, color: 'good', teamDomain: null, token: null,
						message: "*Pipeline built successfully!* ${env.JOB_NAME}*! (<!here|here>)"
					}
				}
			}
		}
	}
}



