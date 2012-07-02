<?php include('MyFunctions.inc.php');

if (isset($_GET["id_keyring"])) $id_keyring = $_GET["id_keyring"]; else $id_keyring = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";

// We get the list of keyrings
$result = mysql_query( "SELECT * FROM `keyrings`" );


if ( $step != "1")
{
?>


<html>
<HEAD>
<TITLE>Keyring Deployment</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="choose_keyring" action="choose_keyring.php" method="post">
    <fieldset><legend>Selecting a keyring to deploy</legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><img src='images/keyring_little.gif'><?php display_availables_keyrings(); ?></td>
        </td>
      </tr>
    </table>
    </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="submit" type="submit" value="Deploy">
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
    $id_keyring = $_POST['keyring'];

    header("Location:decrypt_key.php?action=deploy_keyring&id_keyring=$id_keyring");
    exit ();
  }
  else
  {
    // Error occurred let's notify it
    echo( $error_list );
  }
}
?>

