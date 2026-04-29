WEBSITE=hatmalik;
WEBSITEEXT=luba;
DBNAMEDEFAULT=hatmalik;
DBUSER=laravel;
DBPASS=laravel;
ADMINUSER=rafiqulranu;
ADMINPASS=rti@2026;
ADMINEMAIL=rafiqul_rti@yahoo.com;
SETUPCOMMAND='composer create-project --prefer-dist laravel/laravel .';

sudo echo'server {
    listen 80;
    server_name ${WEBSITE}.${WEBSITEEXT};
    root /var/www/${WEBSITE}/public_html/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.php index.html index.htm ;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    access_log /var/www/${WEBSITE}/public_html/storage/logs/nginx-access.log;
    error_log /var/www/${WEBSITE}/public_html/storage/logs/nginx-error.log;
    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}'> /etc/nginx/site-available/${WEBSITE}.conf;

mysql -u ${DBUSER} -p${DBPASS} << EOF
create database ${DBNAMEDEFAULT};
use ${DBNAMEDEFAULT};
CREATE TABLE ${DBNAMEDEFAULT}.places (id INT AUTO_INCREMENT, name VARCHAR(255), visited BOOLEAN, PRIMARY KEY(id));
INSERT INTO ${DBNAMEDEFAULT}.places (name, visited) VALUES ("Tokyo", false),("Budapest", true),("Nairobi", false),("Berlin", true),("Lisbon", true),("Denver", false),("Moscow", false),("Olso", false),("Rio", true),("Cincinnati", false),("Helsinki", false);
EOF
sudo mkdir -p /var/www/${WEBSITE}/public_html && sudo chown -R $USER:www-data /var/www/${WEBSITE};
cd /var/www/${WEBSITE}/public_html/
${SETUPCOMMAND};
sudo systemctl restart nginx php8.3-fpm
sudo chown -R $USER:www-data /var/www/${WEBSITE};
sudo chmod -R g+w storage;
sed -i "s/APP_NAME=Laravel/APP_NAME=${WEBSITE}/g" /var/www/${WEBSITE}/public_html/.env;
sed -i "s/APP_ENV=local/APP_ENV=development/g" /var/www/${WEBSITE}/public_html/.env;
sed -i "s/APP_URL=http:\/\/localhost/APP_URL=http:\/\/${WEBSITE}.${WEBSITEEXT}/g" /var/www/${WEBSITE}/public_html/.env;
sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/g" /var/www/${WEBSITE}/public_html/.env;
sed -i "s/# DB_DATABASE=laravel/DB_DATABASE=${DBNAMEDEFAULT}/g" /var/www/${WEBSITE}/public_html/.env;
sed -i "s/# DB_USERNAME=root/DB_USERNAME=${DBUSER}/g" /var/www/${WEBSITE}/public_html/.env;
sed -i "s/# DB_PASSWORD=/DB_PASSWORD=${DBPASS}/g" /var/www/${WEBSITE}/public_html/.env;
mv routes/web.php routes/web.php-back;
echo "<?php
/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the 'web' middleware group. Now create something great!
|
*/
/* use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

*/
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    $visited = DB::select('select * from places where visited = ?', [1]);
    $togo = DB::select('select * from places where visited = ?', [0]);
    return view('${WEBSITE}', ['visited' => $visited, 'togo' => $togo]);
});
"> /var/www/${WEBSITE}/public_html/routes/web.php;
echo '<html>
<head>
	<title>Travel List</title>
</head>
<body>
	<h1>My Travel Bucket List</h1>
	<h2>Places I would Like to Visit</h2>
	<ul>
	  @foreach ($togo as $newplace)
		<li>{{ $newplace->name }}</li>
	  @endforeach
	</ul>

	<h2>Places I have Already Been To</h2>
	<ul>
          @foreach ($visited as $place)
                <li>{{ $place->name }}</li>
          @endforeach
	</ul>
</body>
</html>' > /var/www/${WEBSITE}/public_html/resources/views/${WEBSITE}.blade.php;

php artisan
php artisan migrate


