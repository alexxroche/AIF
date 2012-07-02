<?php include('MyFunctions.inc.php');

$id = $_GET['id'];
$host_name = $_GET['host_name'];

// We get the list of groups
$result = mysql_query( "SELECT * FROM `groups`" );
$step = $_POST['step'];

if ( $step != "1")
{
?>


<html>
<HEAD>
<TITLE>Hosts - groups Association</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="setup_hg" action="hg_setup.php" method="post">
    <fieldset><legend>Select new group for host <?php echo("$host_name");?></legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><?php display_available_groups(); ?></td>
        </td>
      </tr>
      </table>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id" type="hidden" value="<?php echo("$id");?>">
      <input name="submit" type="submit" value="Change">
      </center>
    </form>
    </center>

<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>

<?php
}
else
{
  $error_list = "";
  if( empty( $error_list ) )
  {
    $host_id = $_POST['id'];
    $group_id = $_POST['group'];

    mysql_query( "update `hosts` set `id_group` = '$group_id' where `id` = '$host_id'" ) or die(mysql_error()."<br>Couldn't execute query: $query");
    header("Location:host-view.php?id_hostgroup=$group_id&id=$host_id");
    echo ("account Added, redirecting...");
    exit ();
  }
  else
  {
    // Error occurred let's notify it
    echo( $error_list );
  }
}
?>

