Notes For Running on AWS C9

Use the Heroku Local run command or this...
$ heroku local

You need to specify a valid host name as a parameter (or add the c9 domain to a site):
http://47207abac59149018fa8d61afa580485.vfs.cloud9.us-east-1.amazonaws.com/?site_host=demo

This is running on the staging database but the file manager, image processing and heroku api etc.
is on live accounts so try not to delete content on customer accounts, stick to the demo account.

Demo Account:
user: demo@sayitright.com
pw: okbyjoe4u

Using RVM needs sudo...
https://forums.aws.amazon.com/thread.jspa?messageID=839014

Ensure bundler does not try to update sass versions as newer ones require ruby 2+




