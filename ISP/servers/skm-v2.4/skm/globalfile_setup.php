<?php include('MyFunctions.inc.php');

if (isset($_POST["id"])) $id = $_POST["id"]; else $id = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";
if($step != '1')
{

  if (!empty($id))
  {
    // We modify an existing reminder
    $result = mysql_query( "SELECT * FROM `globalfiles` where `id`='$id'" );
    $row = mysql_fetch_array( $result );
    $name = $row["name"];
    $text = $row["text"];
    $path = $row["path"];
    $localfile = $row["localfile"];
  }
  else {
	$name = "";
	$text = "";
	$path = "";
	$localfile = "";
  }
?>


<html>
<HEAD>
<TITLE>global file Setup</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="setup_globalfile" action="globalfile_setup.php" method="post">
    <fieldset><legend>Add / Modify a global file</legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type">name : </td>
        <td class="Content" width="80%">
        <input name="name" size="50" type="text" maxlength="255" value="<?php echo("$name"); ?>">
	</td>
      </tr>
      <tr>
        <td class="Type">Destination path : </td>
        <td class="Content" width="80%">
        <input name="path" size="50" type="text" maxlength="255" value="<?php echo("$path"); ?>">
        </td>
      </tr>
      <tr><td><br></td></tr>
      <tr>
        <td class="Type">Local file path and name : </td>
        <td class="Content" width="80%">
        <input name="localfile" size="50" type="text" maxlength="255" value="<?php echo("$localfile"); ?>">
        </td>
      </tr>
      <tr><td><br></td></tr>
      </table>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id" type="hidden" value="<?php echo("$id");?>">
      <input name="submit" type="submit" value="add/modify">
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
    $id = $_POST['id'];
    if(empty($id)){
    // this is a new reminder
      $name = $_POST['name'];
      $path = $_POST['path'];
      $localfile = $_POST['localfile'];
      // No error let's add the entry
      mysql_query( "INSERT INTO `globalfiles` (`name`, `path`, `localfile`) VALUES('$name','$path','$localfile')" ) or die(mysql_error()."<br>Couldn't execute query: $query");
      header("Location:globalfile.php");
      exit ();
    } else {
      $name = $_POST['name'];
      $path = $_POST['path'];
      $text = $_POST['localfile'];
      mysql_query( "UPDATE `globalfiles` SET `name` = '$name', `path` = '$path', `localfile` = '$localfile' WHERE `id` = '$id' " );
      header("Location:globalfile.php");
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

