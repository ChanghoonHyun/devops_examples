cd $1
rm -f .env
echo "DB_HOST=$3" >> .env
echo "DB_USER=$4" >> .env
echo "DB_PASSWORD=$5" >> .env
echo "DB_PORT=$6" >> .env
zip ../app-$2.zip -r * .[^.]*