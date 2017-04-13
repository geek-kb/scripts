export ANT_HOME_1_7_0=/workspace/development/org/apache/ant/1.7.0
export ANT_HOME=$ANT_HOME_1_7_0
export PATH=$ANT_HOME/bin:$PATH
export JAVA_HOME_1_6_0=/workspace/development/com/sun/jdk
export JAVA_HOME=$JAVA_HOME_1_6_0
export PATH=$JAVA_HOME/bin:$PATH
export ENVIRONMENT_TYPE=prod
export CVS_RSH=${CVS_RSH-ssh}# change default from rsh to ssh for cvs command
export TOMCAT_HOME_6_0_41=/workspace/development/org/apache/tomcat/6.0.41
export TOMCAT_HOME=$TOMCAT_HOME_6_0_41
export PATH=$PATH:$TOMCAT_HOME/bin
export VOLDEMORT_HOME=/workspace/development/voldemort-0.80.1/config/test_config3
export LOCATION=nyc

# a list of peer39 aliases

alias cdui="cd /workspace/development/org/apache/tomcat/6.0.29/webapps/"
alias cdlog="cd /var/log/peer39/"
alias cdprod="cd /workspace/production/"
alias cdbin="cd /workspace/development/org/apache/tomcat/6.0.29/bin"
alias cdsoft="cd /backup/software/peer39/"
alias cdscript="cd /backup/scripts"
export DNS=199.108.95.210
alias takam="tail -50f /var/log/akam.log"
alias akam="tail -50f /var/log/akam.log | grep -vi trucker"
#alias lb_out='cd /workspace/production/proxy/peer39-proxy/WEB-INF/scripts/; ./setValue.sh /workspace/temp/1.txt removethatkeypls'
#alias lb_in='cd /workspace/production/proxy/peer39-proxy/WEB-INF/scripts/ ; ./setValue.sh /workspace/temp/1.txt ppp'
alias lb_in='cd /workspace/production/proxy/peer39-proxy/WEB-INF/scripts/ && ./setValue.sh /workspace/temp/1.txt ppp && ./setValue.sh /workspace/temp/1 1'
alias lb_out='cd /workspace/production/proxy/peer39-proxy/WEB-INF/scripts/ && ./setValue.sh /workspace/temp/1.txt rrr && ./setValue.sh /workspace/temp/1 0'
alias kill_proxy='cd /workspace/production/proxy/peer39-proxy/WEB-INF/scripts/ && ./shutdown.sh'
