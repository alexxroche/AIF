<?php include('MyFunctions.inc.php');?>

<html>
<HEAD>
<TITLE>Searching for a host model number</TITLE>
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
    <form name="model_search" action="model_search.php" method="post">
    <fieldset><legend>Looking for a host model number</legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type" width="40%">Model Number : </td>
        <td class="Content" width="60%">
        <input name="model" size="50" type="text" maxlength="255" value="">
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
  $model = $_POST["model"];
  $modelsearch = "%"."$model"."%";



  print("<center><fieldset><legend>Searching for model number $model</legend>");

  $result = mysql_query( "SELECT * FROM `hosts` where `model` LIKE '$modelsearch' ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");

  $nr = mysql_num_rows( $result );
  if(empty($nr)) {
      echo("No host found with that model number...\n");
  }
  else {
      print("<table class='listegenerale'><tr><td>Serveur</td><td># Serie</td><td>Systeme d'exploitation</td><td># processeurs</td><td>Fournisseur</td><td>Model</td></tr>");
      $even=0;
      while( $row = mysql_fetch_array( $result ))
      	{
		$id=$row['id'];
		$id_hostgroup=$row['id_group'];
		$hostname=$row['name'];
		$serialno=$row['serialno'];
                $os=$row['osversion'];
                $proc=$row['procno'];
                $fourn=$row['provider'];
                $model=$row['model'];
		        // displaying rows
        if ( $even == 0) { echo("<tr class='even'>\n"); $even++; } else { echo("<tr>\n"); $even=0; }
		print("<td><a href='hosts_setup.php?id=$id&id_hostgroup=$id_hostgroup'>$hostname</td></a><td><a href='hosts_setup.php?id=$id&id_hostgroup=$id_hostgroup'>$serialno</a></td><td>$os</td><td>$proc</td><td>$fourn</td><td>$model</td></tr>\n");
	}
      print("</table>");
  }
}

end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>
