<?php include('MyFunctions.inc.php');

if($_POST['step'] != '1')
{

  $id_gfile = $_GET['id'];
?>


<html>
<HEAD>
<TITLE>Global File Deployment</TITLE>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="deploy_gfile" action="deploy_gfile.php" method="post">
    <fieldset><legend>Deploying <?php echo $name?></legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type">Select destination host : </td>
        <td class="Content" width="60%">
        <?php display_available_hosts(); ?>
        </td>
      </tr>
      </table>
      </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="id_gfile" type="hidden" value="<?php echo("$id_gfile");?>">
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
    $id = $_POST['id_gfile'];
    if(!empty($id)){
      $host = $_POST['host']; ?>

<html>
<HEAD>
<TITLE>Global File Deployment</TITLE>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <fieldset><legend>Deploying <?php print get_gfile_name($id);?> on host <?php print get_host_name($host);?></legend>
       <?php echo deploy_globalfile($id,$host) ?>
    </fieldset>

<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>

<?php
    }

unlink($home_of_webserver_account."/.ssh/id_rsa") or die("ATTENTION : Private key file ".$home_of_webserver_account."/.ssh/id_rsa could not be deleted");

}
?>

