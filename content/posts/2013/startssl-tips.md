---
date: "2013-09-01T15:11:46Z"
tags:
- programming
title: StartSSL tips
tumblr_url: http://joonas-fi.tumblr.com/post/59966941169/startssl-tips
url: /2013/09/01/startssl-tips/
---
(this post is mainly my own notes, so it might not be that useful, but I decided to post it anyway so I'll find it later)

[startssl.com](http://www.startssl.com/)

Renew the client certificate in the browser
===========================================

1) Validate your email

   "Validations Wizard" > Email address validation > startcom.001@sentinel.xs.fi

   Check your email for the validation code

   Enter it in the question box

2) Create certificate for your email

   Certificates wizard > Certificate target: S/Mime and authentication


Get a website certificate
=========================

1) Validate your domain

   1.1) "Validations Wizard" > Domain name validation > [domain]

   1.2) Email: webmaster@[domain]

   1.3) Check your email for the validation code

   1.4) Enter it in the question box

2) Go to Certificates wizard > Web server TLS certificate > Skip

3) Let's sign a CSR in your own environment:

   3.1) ONLY IF you don't have private key generated yet:

        $ openssl genrsa -out ssl.key 2048

   3.2) Generate CSR (Certificate Signing Request) file.

        $ openssl req -new -key ssl.key -batch -out [domain].csr

        (The -batch switch only works with StartSSL.com, because all they grab from .csr is the public key)

   3.3) Paste the contents of the .csr file to startssl

   3.4) Add "www" as the subdomain, or something else if you know what you're doing

   3.5) Continue > Download the signed .crt file. Save it as [domain].crt

   3.6) You can safely remove the .csr (signing request) file

   3.7) In the settings of your tls-compliant software, point to the ssl.key and [domain].crt files

        Optionally, you can bake them all into one file: cat ssl.key [domain].crt > certs.pem


Hat tips
========

For a few tips and tricks: [http://n8.io/setting-up-free-ssl-on-your-node-server/](http://n8.io/setting-up-free-ssl-on-your-node-server/)
