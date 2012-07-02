<?php
	include('MyFunctions.inc.php');
	@$aix = $_GET['aix'];
	@$rhel = $_GET['rhel'];
	@$solaris = $_GET['solaris'];
	@$id = $_GET['id'];
	@$action = $_GET['action'];
	@$id_hostgroup = $_GET['id_hostgroup'];
?>

<html>
<head>
  <title>SKM - Display Host list</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
  <script src="sorttable.js"></script>
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

  <!-- <fieldset><legend><?php print get_group_name($id_hostgroup);?> host List <a href="hosts_setup.php?id_hostgroup=<?php echo $id_hostgroup?>">[create a new host]</a> </legend> -->
<?php
if(isset($_GET["id_hostgroup"]))
{
  ?>
  <table class=sortable>
	
    <?php
    echo ("<caption>"); print get_group_name($id_hostgroup); echo ("</caption>");
    $SQLQUERY="SELECT * FROM `hosts` where `id_group` = '$id_hostgroup' ORDER BY `ostype` DESC, `name` ASC";
    if ( $aix == "Y" ) $SQLQUERY = "$SQLQUERY AND `ostype` = 'AIX'";
    if ( $rhel == "Y" ) $SQLQUERY = "$SQLQUERY AND `ostype` = 'RHEL'";
    if ( $solaris == "Y" ) $SQLQUERY = "$SQLQUERY AND `ostype` = 'solaris'";
    $result = mysql_query( $SQLQUERY )
                         or die (mysql_error()."<br>Couldn't execute query: $SQLQUERY");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      //echo("<tr><td class='detail1'>No host defined</td><td class='detail2'></td></tr>\n");
      echo("<tr><td class='detail1'>No host defined</td></tr>\n");
    }
    else {
      echo ("<thead><tr><th>icon</th><th>Hostname</th><th>IP @</th><th>Serial #</th><th>OS type</th><th>OS Version</th><th>Monitor</th></tr></thead>");
      echo ("<tbody>");
      $odd=1;
      while( $row = mysql_fetch_array( $result )) 
      {
        // Affecting values
        $name = $row["name"];
	    $ip = $row["ip"];
        $id = $row["id"];
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
	    } 
		else {
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
		echo("	<td><a href='host-view.php?id=$id&id_hostgroup=$id_hostgroup'>$name</a></td>");
		echo("	<td>$ip</td>");
		echo("	<td>$serialno</td>");
		echo("	<td>$ostype</td>");
		echo("	<td>$osvers</td>");
		if (!empty($monitor)) echo("	<td><img src='images/ok.gif'></td>"); else echo(" <td></td>");
      }

      mysql_free_result( $result );
      echo("</tr></tbody></table>");
    }
  }
  else
  {
	echo "<script type=\"text/javascript\">window.location.href = 'show_all_hosts.php'</script>";
  }
  ?>
 
</td></tr></table>

<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>
