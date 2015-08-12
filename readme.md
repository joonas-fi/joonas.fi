
Setting up the VM
=================

	$ sudo apt-get update && sudo apt-get install -y vim make nodejs ruby1.9.3 && sudo gem install --no-ri --no-rdoc jekyll jekyll-tagging


Configuration
=============

Edit /blog/_config.yml

Previewing the blog
===================

Run:

	$ ./preview.sh

Deploying the blog
==================

Just run:

	$ ./deploy.sh
