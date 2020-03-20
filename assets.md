Notes on asset storage which needs updating.

The upload and processing is using very old code before we had the ability to do easily do direct secured uploads, hence why we have multiple buckets?

Storage

Files are uploaded to udn.sayitright.com bucket - I think this was because we needed it unsecured for original uploaders or encoders?
Files are stored in fdn.sayitright.com bucket

The fdn storage bucket is secured so files need to be accessed through cloudfront
until we can figureout how to give filestack direct access, else we are doing an 
extra http request on our cdn every time
d2sx8wqw5d2a0f.cloudfront.net

dont use the cdn.sayitright.com domain as its not https

For example the mm logo is:
https://fdn.sayitright.com.s3.amazonaws.com/sites/51fe326d9d1e88274000000f/logo
And available on the cdn at:
https://d2sx8wqw5d2a0f.cloudfront.net/sites/51fe326d9d1e88274000000f/logo

New Filestack API is:
https://cdn.filestackcontent.com/YOUR APIKEY/TASKS/URL