<?php
 // mysql connection data
 //  default: localhost
 $mysql_host = "localhost";
 //  default: skmadmin
 $mysql_user = "skmadmin";
 //  default: demo
 $mysql_pass = "yourpass";
 //  default: skm
 $mysql_db = "skm";
 
 // home directory of the webserver user, containing .ssh directory etc.
 // no trailing slash required
 // example: $home_of_webserver_account = "/var/www";
 $home_of_webserver_account = "/var/empty";
 $gpgbin = "/usr/bin/gpg";
 $admin_email = "youremail@yourdomain.com";

 // Configuration for ssh connection
 // sudouser is the name of the remote unix account used to manage ssh keys.
 $sudousr = "root";
?>
