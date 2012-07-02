<?php
include('database.inc.php');

// We cleanup records older than 3 days
$result = mysql_query( "SELECT * FROM `hosts` where `main_end_dt` < date_sub(current_date, interval 60 day)" ) or die(mysql_error()."<br>Couldn't execute query: $query");

?>

