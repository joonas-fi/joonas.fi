---
date: "2015-04-18T10:24:41Z"
tags:
- programming
title: Publishing S3 events to SNS or SQS
tumblr_url: http://joonas-fi.tumblr.com/post/116709891827/publishing-s3-events-to-a-sns-or-sqs
url: /2015/04/18/publishing-s3-events-to-sns-or-sqs/
---

In SNS
======

Create a SNS topic, if you haven’t already.

Go to actions > Edit topic policy

Add this item to the “Statement” array:

	{
	   "Sid": "example-statement-ID",
	   "Effect": "Allow",
	   "Principal": {
	     "Service": "s3.amazonaws.com"
	   },
	   "Action": [
	    "SNS:Publish"
	   ],
	   "Resource": "SNS-ARN",
	   "Condition": {
	      "ArnLike": {
	      "aws:SourceArn": "arn:aws:s3:*:*:your-s3-bucket-name"
	    }
	   }
	}

Note: For “Sid”, you can choose anything, f.ex. “s3-publish-events”

In the “Resource” you put the ARN of the SNS Topic.

Remember to also replace the your-s3-bucket-name in the “SourceArn” condition.

In S3
=====

Go to bucket Properties > Events > Add notification

For Event, use “ObjectCreated (All)” and input your topic ARN into the field.

Upon saving, S3 will validate that it has publish rights to the SNS topic.

In SQS
======

Go to Permissions > Edit policy document.

Insert this into the “Statement” array:

	{
	     "Sid": “example-statement-id”,
	     "Effect": “Allow”,
	     "Principal": {
	       "AWS": “*”
	     },
	     "Action": “SQS:SendMessage”,
	     "Resource": “SQS-ARN”,
	     "Condition": {
	       "ArnLike": {
	         "aws:SourceArn": “arn:aws:s3:*:*:your-s3-bucket-name”
	       }
	     }
	}

Same advice goes as for the SNS policy document.
