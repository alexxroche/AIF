<?php include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id_host = $_GET["id"]; else $id_host = "";
if (isset($_GET["host_name"])) $host_name = $_GET["host_name"]; else $host_name = "";
if (isset($_GET["id_hostgroup"])) $id_hostgroup = $_GET["id_hostgroup"]; else $id_hostgroup = "";
if (isset($_POST["account"])) $id_account = $_POST["account"]; else $id_account = "";

// We get the list of accounts
$result = mysql_query( "SELECT * FROM `accounts`" );

if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";
if($step != '1')
{
?>


<html>
<HEAD>
<TITLE>Hosts - Accounts Association</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="setup_ha" action="ha_setup.php" method="post">
    <fieldset><legend>Adding Account(s) to host <?php echo("$host_name");?></legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><?php display_availables_accounts(); ?></td>
        </td>
      </tr>
      </table>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id_hostgroup" type="hidden" value="<?php echo $id_hostgroup?>">
      <input name="id" type="hidden" value="<?php echo $id_host?>">
      <input name="submit" type="submit" value="add">
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
	$id_host = $_POST['id'];
    $id_hostgroup = $_POST['id_hostgroup'];

    mysql_query( "INSERT INTO `hosts-accounts` (`id_host`, `id_account`, `expand`) VALUES('$id_host','$id_account','Y')" ) or die(mysql_error()."<br>Couldn't execute query");
    header("Location:host-view.php?id_hostgroup=$id_hostgroup&id=$id_host");
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

