channel = "#general"
def color
def message
def slackSend(color) {
		if ("${color}"=='danger') {
			def message="*Failed to build ${env.JOB_NAME}*! :x: (<!here|here>"
			echo "Pipeline didn't finish!"
		} else if ("${color}"=='good') {
			def message="*Pipeline built successfully!* ${env.JOB_NAME}*! :x: (<!here|here>)"
			echo "Pipeline finished successfully"
		}
		slackSend channel: channel, color: 'danger', teamDomain: null, token: null,
		message: "${message} ${env.JOB_NAME}*! :x: (<!here|here>)"
}

try {
	stage ('test') {
		node {
			CWD=pwd()
			print CWD
			checkout scm
		}
	}
} catch (err) {
		currentBuild.result = 'FAILURE'
		color='danger'
		slackSend(danger)
		}

stage ('whatever') {
	print "Current build result: ${currentBuild.result}"
}

if ("${currentBuild.result}"=='null') {
	currentBuild.result = 'SUCCESS'
	color='good'
	print "Current build result: ${currentBuild.result}"
	slackSend(good)
}
