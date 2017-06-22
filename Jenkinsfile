pipeline {
	agent any
	options { disableConcurrentBuilds() }
	stages {
		stage ('Downloading project') {
			steps {
				channel = "#general"
				try {
					node {
						checkout scm
					}
				} catch (err) {
					currentBuild.result = 'FAILURE'
					slackSend channel: channel, color: 'danger', teamDomain: null, token: null,
					message: "*Failed to build ${env.JOB_NAME}*! :x: (<!here|here>)"
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
				if (!currentBuild.result) {
					currentBuild.result = 'SUCCESS'
					slackSend channel: channel, color: 'good', teamDomain: null, token: null,
					message: "*Pipeline built successfully!* ${env.JOB_NAME}*! (<!here|here>)"
				}
			}
		}
	}
}

