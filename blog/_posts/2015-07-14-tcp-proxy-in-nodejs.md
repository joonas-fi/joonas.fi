---
layout:     post
title:      TCP proxy in node.js
date:       2015-07-14 19:03:00
# summary:    This is an empty post to illustrate the pagination component with Pixyll.
---

See also my answer in [StackOverflow](http://stackoverflow.com/questions/6490898/node-js-forward-all-traffic-from-port-a-to-port-b/19637388#19637388).

{% highlight javascript %}
var net = require('net');

// parse "80" and "localhost:80" or even "42mEANINg-life.com:80"
var addrRegex = /^(([a-zA-Z\-\.0-9]+):)?(\d+)$/;

var addr = {
    from: addrRegex.exec(process.argv[2]),
    to: addrRegex.exec(process.argv[3])
};

if (!addr.from || !addr.to) {
    console.log('Usage: <from> <to>');
    return;
}

net.createServer(function(from) {
    var to = net.createConnection({
        host: addr.to[2],
        port: addr.to[3]
    });
    from.pipe(to);
    to.pipe(from);
}).listen(addr.from[3], addr.from[2]);
{% endhighlight %}
