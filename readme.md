
Preparing the server for the remote deploy script
=================================================

Edit the script: `serverside_deploy.sh`

Then copy this script to your home directory on the server.

Deploying the blog
==================

Just run:

	$ ./deploy.sh

Install jekyll & other prerequisites
====================================

	$ sudo apt-get update && sudo apt-get install -y vim make nodejs ruby1.9.3

	$ sudo gem install --no-ri --no-rdoc jekyll

