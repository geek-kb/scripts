pipeline {
	agent any
	options { disableConcurrentBuilds() }
	environment {
		channel = "#general"
		jenkins_creds = "polling-user"
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
						slackSend channel: env.channel, color: 'danger', teamDomain: null, token: null,
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
					withCredentials([[$class: 'UsernamePasswordMultiBinding', 
					credentialsId: jenkins_creds, usernameVariable: 'J_USER', 
					passwordVariable: 'J_PASS'], 
					]){
					cmd = "curl -s --insecure -u ${J_USER}:${J_PASS} ${BUILD_URL}api/json | python -mjson.tool | grep fullName | awk 'NR==1' | cut -d'\"' -f4 "
					issuer = sh(returnStdout: true, script: cmd).trim
					}
					
					if (!currentBuild.result) {
						currentBuild.result = 'SUCCESS'
						slackSend channel: channel, color: 'good', teamDomain: null, token: null,
						message: "*Pipeline built successfully by ${issuer}!* ${env.JOB_NAME}*! (<!here|here>)"
					}
				}
			}
		}
	}
}
