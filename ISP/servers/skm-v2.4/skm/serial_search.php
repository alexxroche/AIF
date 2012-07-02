<?php include('MyFunctions.inc.php');?>

<html>
<HEAD>
<TITLE>Searching for a host serial number</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

<?php
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";
if($step != '1')
{

?>
    <center>
    <form name="serial_search" action="serial_search.php" method="post">
    <fieldset><legend>Looking for a host serial number</legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type" width="40%">Serial Number : </td>
        <td class="Content" width="60%">
        <input name="serial" size="50" type="text" maxlength="255" value="">
        </td>
      </tr>
    </table>
    </fieldset>

    <center>
      <input name="step" type="hidden" value="1">
      <input name="submit" type="submit" value="Search">
    </center>
    </form>
    </center>

<?php
}
else
{
  $serial = $_POST["serial"];
  $serialsearch = "%"."$serial"."%";



  print("<center><fieldset><legend>Searching for serial number $serial</legend>");

  $result = mysql_query( "SELECT * FROM `hosts` where `serialno` LIKE '$serialsearch' ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");

  $nr = mysql_num_rows( $result );
  if(empty($nr)) {
      echo("No host found with that serial number...\n");
  }
  else {
      print("<table class='listegenerale'><tr><td>Server</td><td># Serie</td><td>Operating System</td><td># Processors</td><td>Supplier</td></tr>");
      $even = 0;
      while( $row = mysql_fetch_array( $result ))
      	{
		$id=$row['id'];
		$id_hostgroup=$row['id_group'];
		$hostname=$row['name'];
		$serialno=$row['serialno'];
                $os=$row['osversion'];
                $proc=$row['procno'];
                $fourn=$row['provider'];
	        if ( $even == 0) { echo("<tr class='even'>\n"); $even++; } else { echo("<tr>\n"); $even=0; }
		print("<td><a href='hosts_setup.php?id=$id&id_hostgroup=$id_hostgroup'>$hostname</td></a><td><a href='hosts_setup.php?id=$id&id_hostgroup=$id_hostgroup'>$serialno</a></td><td>$os</td><td>$proc</td><td>$fourn</td></tr>\n");
	}
      print("</table>");
  }
}

end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>
