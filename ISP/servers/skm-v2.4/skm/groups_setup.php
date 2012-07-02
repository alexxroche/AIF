<?php include('MyFunctions.inc.php');

if (isset($_POST["id"])) $id = $_POST["id"]; else $id = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";
if($step != '1')
{
  if (!empty($id))
  {
    // We modify an existing reminder
    $result = mysql_query( "SELECT * FROM `groups` where `id`='$id'" );
    $row = mysql_fetch_array( $result );
    $name = $row["name"];
  }
  else 	$name = "";
?>


<html>
<HEAD>
<TITLE>Group Setup</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="setup_group" action="groups_setup.php" method="post">
    <fieldset><legend>Add / Modify a group of host</legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type">Name : </td>
        <td class="Content" width="80%">
        <input name="name" size="50" type="text" maxlength="255" value="<?php echo("$name"); ?>">
        </td>
      </tr>
      <tr><td><br></td></tr>
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
    if(empty($id)){
    // this is a new reminder
      $name = $_POST['name'];
      // No error let's add the entry
      mysql_query( "INSERT INTO `groups` (`name`) VALUES('$name')" ) or die(mysql_error()."<br>Couldn't execute query: $query");
      // Let's go to the Reminder List page
      //if (empty($_POST['called']))
      //  header("Location:reminder_list.php");
      //else
      header("Location:groups.php");
      exit ();
    } else {
      // We modify an existing reminder
      // setting the variable for the update
      $name = $_POST['name'];
      mysql_query( "UPDATE `groups` SET `name` = '$name' WHERE `id` = '$id' " );
      // Let's go to the Reminder List page
      header("Location:groups.php");
      exit ();
    }

  }
  else
  {
    // Error occurred let's notify it
    echo( $error_list );
  }
}
?>

