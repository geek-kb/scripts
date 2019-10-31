channel = "#general"
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
		slackSend channel: channel, color: 'danger', teamDomain: null, token: null,
		message: "*Failed to build ${env.JOB_NAME}*! :x: (<!here|here>)"
		echo "Pipeline didn't finish!"
		}

stage ('whatever') {
	print "Current build result: ${currentBuild.result}"
}

if ("${currentBuild.result}"=='null') {
	currentBuild.result = 'SUCCESS'
	print "Current build result: ${currentBuild.result}"
	slackSend channel: channel, color: 'good', teamDomain: null, token: null,
	message: "*Pipeline built successfully!* ${env.JOB_NAME}*! :x: (<!here|here>)"
	echo "Pipeline finished successfully"
}
