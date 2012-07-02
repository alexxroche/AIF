<?php include('MyFunctions.inc.php');

if (isset($_GET["aix"])) $aix = $_GET["aix"]; else $aix = "";
if (isset($_GET["rhel"])) $rhel = $_GET["rhel"]; else $rhel = "";
if (isset($_GET["solaris"])) $solaris = $_GET["solaris"]; else $solaris = "";
if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_GET["action"])) $action = $_GET["action"]; else $action = "";

?>

<html>
<HEAD>
<TITLE>All Hosts Overview</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php

start_main_frame();
start_left_pane();
display_menu();
end_left_pane();
start_right_pane();

//print("<center><fieldset><legend>All Hosts Overview</legend>");

$result = mysql_query( "SELECT * FROM `hosts` ORDER BY `name`" )
					 or die (mysql_error()."<br>Couldn't execute query: $query");

$nr = mysql_num_rows( $result );
if(empty($nr)) 
{
	echo("No hosts found ...\n");
}
else 
{
?>
  <table class=sortable>
  
    <?php
	echo ("<center><fieldset><legend>All Hosts Overview</legend>");
	//print("<table class='listegenerale'><tr><td>Server</td><td># Serie</td><td>Operating System</td><td># Processors</td><td>Supplier</td></tr>");
	echo ("<thead><tr><th>icon</th><th>Hostname</th><th>IP @</th><th>Serial #</th><th>OS type</th><th>OS Version</th><th>Monitor</th></tr></thead>");
    echo ("<tbody>");
      $odd=1;
      while( $row = mysql_fetch_array( $result )) 
      {
        // Affecting values
        $name = $row["name"];
	    $ip = $row["ip"];
        $id = $row["id"];
		$id = $row["id"];
		$id_group = $row["id_group"];
		$ostype = $row["ostype"];
		$osvers = $row["osvers"];
		$monitor = $row["monitor"];
		$direction = $row["id_direction"];
		$serialno = $row["serialno"];
		  
			// displaying rows
		if ( $odd==1 )
		{
			$odd=0;
			echo("<tr class=odd>");
		} else {
			$odd+=1;
			echo("<tr>\n");
		}

		// getting the right icon
		$icon="images/server.gif";
		if ( $row['ostype'] == "RHEL" ) $icon="images/icon-redhat.gif";
		if ( $row['ostype'] == "AIX" ) $icon="images/icon-aix.gif";
		if ( $row['ostype'] == "Solaris" ) $icon="images/icon-solaris.gif";
		if ( $row['ostype'] == "Windows" ) $icon="images/icon-windows.gif";
		if ( $row['ostype'] == "FreeBSD" ) $icon="images/icon-freebsd.gif";

		echo("  <td class='title'><img src='$icon' border='0'></td>");
		echo("	<td><a href='host-view.php?id=$id&id_hostgroup=$id_group'>$name</a></td>");
		echo("	<td>$ip</td>");
		echo("	<td>$serialno</td>");
		echo("	<td>$ostype</td>");
		echo("	<td>$osvers</td>");
		if (!empty($monitor)) echo("	<td><img src='images/ok.gif'></td>"); else echo(" <td></td>");
    }

    mysql_free_result( $result );
    echo("</tr></tbody></table>");

}

echo("</td></tr></table>");
end_right_pane();
end_main_frame(); 

?>

</body>
</html>
