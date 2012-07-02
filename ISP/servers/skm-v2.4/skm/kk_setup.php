<?php include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_GET["keyring_name"])) $keyring_name = $_GET["keyring_name"]; else $keyring_name = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";

// We get the list of keys
$result = mysql_query( "SELECT * FROM `keys`" );

//    echo("kk_setup called with : id=$id, keyring_name=$keyring_name, step=$step\n"); 

if($step != '1')
{
?>
<html>
<HEAD>
<TITLE>Keyrings - keys Association</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="setup_kk" action="kk_setup.php" method="post">
    <fieldset><legend>Adding key(s) to keyring <?php echo("$keyring_name");?></legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><?php display_availables_keys(); ?></td>
        </td>
      </tr>
      </table>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id" type="hidden" value="<?php echo("$id");?>">
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
    $keyring_id = $_POST['id'];
    $key_id = $_POST['key'];

    //echo ("key_name = $key_name, key_id = $key_id, keyring_id = $keyring_id"); exit ();

    mysql_query( "INSERT INTO `keyrings-keys` (`id_keyring`, `id_key`) VALUES('$keyring_id','$key_id')" ) or die(mysql_error()."<br>Couldn't execute query: $query");
    header("Location:keyrings.php");
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

