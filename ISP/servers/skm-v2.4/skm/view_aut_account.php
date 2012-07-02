<?php
include('MyFunctions.inc.php');

$id = $_GET['id'];
$id_account = $_GET['id_account'];
$id_hostgroup = $_GET['id_hostgroup'];

if(!empty($id) and !empty($id_account))
{

?>


<html>
<head>
  <title>Deployment process</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

<?php


$hostname = get_host_name($id);
$account_name = get_account_name($id_account); 

echo("<fieldset><legend>Constructing securities for $account_name on host $hostname</legend>\n");

$output = prepare_authorizedkey_file($id,$id_account); ?>

<table class="detail">
  <tr>
    <td class="deployment">

      <?php echo("$output\n"); ?>

    </td>
  </tr>
</table>

</fieldset>

<?php echo("<fieldset><legend>File authorized_keys2 for $account_name on host $hostname</legend>\n"); 

$output = view_authorizedkey_file($id,$id_account); ?>

<table class="detail">
  <tr>
    <td class="deployment">

      <?php echo("$output\n"); ?>

    </td>
  </tr>
</table>

<?php echo("<center><a href='host-view.php?id=$id&id_hostgroup=$id_hostgroup'>Click here to return to $hostname details</a></center>"); ?>

</fieldset>


<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>
<?
} else {
        die("This page cannot be called without argument...");
} ?>

