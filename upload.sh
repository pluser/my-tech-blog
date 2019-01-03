#!/bin/sh
rsync -a public/ blog.pluser.net:public_html/blog.pluser.net/
curl http://www.google.com/ping?sitemap=https://blog.pluser.net/sitemap.xml
