# sysdig_aws_installer
Installer for Sysdig in AWS

This will install Sysdig with good yaml files in AWS.  You will need route53 access in aws to do so.  You will also need kubectl and awscli configured on the host that is running the scripts.  Lastly, change the hostedid in framework.sh 


This will need a few licenses as well.  The main thing here is the frameowork.sh.  I built in the functions that I need to easily adapt an install to almost any situation.  I am able to gather a few details, modify yamls and using framework.sh easily deploy sysdig in about 20 lines of code.
