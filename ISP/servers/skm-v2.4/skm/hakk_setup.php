<?php include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_GET["host_name"])) $host_name = $_GET["host_name"]; else $host_name = "";
if (isset($_GET["id_account"])) $id_account = $_GET["id_account"]; else $id_account = "";
if (isset($_GET["account_name"])) $account_name = $_GET["account_name"]; else $account_name = "";
if (isset($_GET["id_hostgroup"])) $id_hostgroup = $_GET["id_hostgroup"]; else $id_hostgroup = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";

// We get the list of keyrings
$result = mysql_query( "SELECT * FROM `keyrings`" );


if($step != '1')
{
?>


<html>
<HEAD>
<TITLE>Hosts - accounts - Key Association</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="setup_hak" action="hakk_setup.php" method="post">
    <fieldset><legend>Adding key(s) to account <?php echo("$account_name"); ?> on host <?php echo("$host_name");?></legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><img src='images/key_little.gif'><?php display_availables_keys(); ?></td>
        </td>
      </tr>
      </table>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id" type="hidden" value="<?php echo("$id");?>">
      <input name="id_hostgroup" type="hidden" value="<?php echo("$id_hostgroup");?>">
      <input name="id_account" type="hidden" value="<?php echo("$id_account");?>">
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
    if (isset($_POST["id"])) $host_id = $_POST["id"]; else $host_id = "";
	if (isset($_POST["id_account"])) $account_id = $_POST["id_account"]; else $account_id = "";
	if (isset($_POST["key"])) $key_id = $_POST["key"]; else $key_id = "";
	if (isset($_POST["id_hostgroup"])) $id_hostgroup = $_POST["id_hostgroup"]; else $id_hostgroup = "";

    //echo ("account_name = $account_name, account_id = $account_id, host_id = $host_id");
    //echo ("Keyring id = $keyring_id, key id = $key_id");
    //die ("We stop here");

    mysql_query( "INSERT INTO `hak` (`id_host`, `id_account`, `id_key`,`expand`) VALUES('$host_id','$account_id','$key_id','Y')" ) or die(mysql_error()."<br>Couldn't execute query: insert host_id=$host_id, account_id=$account_id, key_id=$key_id [$query]");
    header("Location:host-view.php?id_hostgroup=$id_hostgroup&id=$host_id");
    echo ("key Added, redirecting...");
    exit ();
  }
  else
  {
    // Error occurred let's notify it
    echo( $error_list );
  }
}
?>

