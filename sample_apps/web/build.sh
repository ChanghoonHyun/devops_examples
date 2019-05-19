cd $1
rm -f .env
echo "API_SERVER=http://$3" >> .env
zip ../web-$2.zip -r * .[^.]*