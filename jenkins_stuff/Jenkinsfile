channel = "#general"

try {
	stage ('Downloading project') {
		node {
			checkout scm
		}
	}
} catch (err) {
		currentBuild.result = 'FAILURE'
		slackSend channel: channel, color: 'danger', teamDomain: null, token: null,
		message: "*Failed to build ${env.JOB_NAME}*! :x: (<!here|here>)"
		}

stage ('whatever') {
	print "Current build result: ${currentBuild.result}"
}

if ("${currentBuild.result}"=='null') {
	currentBuild.result = 'SUCCESS'
	color = 'good'
	slackSend channel: channel, color: 'good', teamDomain: null, token: null,
	message: "*Pipeline built successfully!* ${env.JOB_NAME}*! (<!here|here>)"
}
