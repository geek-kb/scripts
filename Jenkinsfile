pipeline {
	agent any
	options { disableConcurrentBuilds() }
	environment {
		channel = "#general"
        	def PERSON = "Itai Ganot"
	}
	stages {
		stage ('Downloading project') {
			steps {
				script {
					try {
						node {
							checkout scm
							sh(returnStdout: true, script: """
								ls -l
								git branch
								echo "Hello ${env.PERSON}"
							""").trim()
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
				script {
					currentBuild.displayName = "# ${BUILD_NUMBER} | ${BRANCH_NAME}"
				}
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
