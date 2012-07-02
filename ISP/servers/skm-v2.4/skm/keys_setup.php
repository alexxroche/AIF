<?php include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";
if($step != '1')
{

  if (!empty($id))
  {
    // We modify an existing reminder
    $result = mysql_query( "SELECT * FROM `keys` where `id`='$id'" );
    $row = mysql_fetch_array( $result );
    $name = $row["name"];
    $key = $row["key"];
  }
  else 
  {
	$name = "";
	$key = "";
  }
?>


<html>
<HEAD>
<TITLE>Key Setup</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <form name="setup_key" action="keys_setup.php" method="post">
    <fieldset><legend>Add / Modify a key</legend>
        <label for "Desc">Description :</label><input name="name" id="Desc" size="50" type="text" maxlength="255" value="<?php echo("$name"); ?>"><br>
        <label for "Key">Key Value :</label><textarea name="key" id="Key" cols="60" rows="12"><?php echo("$key"); ?></textarea>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id" type="hidden" value="<?php echo("$id");?>">
      <input name="submit" type="submit" value="add">
      </center>
    </form>

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
    $id = $_POST['id'];
    if(empty($id)){
    // this is a new reminder
      $name = $_POST['name'];
      $key = $_POST['key'];
      // No error let's add the entry
      mysql_query( "INSERT INTO `keys` (`name`, `key`) VALUES('$name','$key')" ) or die(mysql_error()."<br>Couldn't execute query: $query");
      // Let's go to the Reminder List page
      //if (empty($_POST['called']))
      //  header("Location:reminder_list.php");
      //else
      header("Location:keys.php");
      echo ("Reminder Added, redirecting...");
      exit ();
    } else {
      // We modify an existing reminder
      // setting the variable for the update
      $name = $_POST['name'];
      $key = $_POST['key'];
      mysql_query( "UPDATE `keys` SET `name` = '$name', `key` = '$key' WHERE `id` = '$id' " );
      // Let's go to the Reminder List page
      header("Location:keys.php");
      echo ("Reminder Modified, redirecting...");
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

