<?php

include('MyFunctions.inc.php');

$id = $_GET['id'];
$id_account = $_GET['id_account'];
$id_group = $_GET['id_hostgroup'];

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

<?php echo("<fieldset><legend>Deploying securities for $account_name on host $hostname</legend>\n"); 

$output = deploy_authorizedkey_file($id,$id_account); ?>

<table class="detail">
  <tr>
    <td class="deployment">

      <?php echo("$output\n"); ?>

    </td>
  </tr>
</table>

</fieldset>

<?php echo "<a href='host-view.php?id_hostgroup=$id_group#$id'><img src='images/arrowbright.gif> Return to $hostname</a>\n"; ?>

<?php
        // We send an email to all users who have an account
        $mailheader = "From: SKM <".$admin_email.">\nX-Mailer: Reminder\nContent-Type: text/html";
        $emailuser = $admin_email;

	$message = "Deploying $account_name to $hostname";
	$message = "$message\t$output";

        mail("$emailuser","SKM: Deploying SSH-Key from $account_name to $hostname.","$message","$mailheader") or die("Could not send mail...");
?>


<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>

<?php 
//We delete the private key file
unlink($home_of_webserver_account."/.ssh/id_rsa") or die("ATTENTION : Private key file ".$home_of_webserver_account."/.ssh/id_rsa could not be deleted");
} else {
	die("This page cannot be called without argument...");
}
