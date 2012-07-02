<?php
include('MyFunctions.inc.php');

$id = $_GET['id'];

if( empty($id) )
{

?>


<html>
<head>
  <title>Accounts List</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

   <fieldset><legend>Create a (non existent) SSH account on a remote server</legend>

   <table class='detail'>
  
    <?php

    $result = mysql_query( "SELECT * FROM `accounts` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );

	?>
	<!--ADDED BY TFISCHER TO FIX ROOT USER ISSUE -->
        <i><font size=2><br>
        <u><b>ATTENTION:</b></u><br>
        There are several requirements for creating remote SSH users:<br>
        <br>
        1) The global sudo user:<b> <? echo $GLOBALS['sudousr']; ?> </b> must exist on the remote host<br>
        (You can change this username in the file MyFunctions.inc.php) <br>
        <br>
        2) This user needs several <b>sudo</b> privileges. Edit /etc/sudoers and add:<br>
	<b>	
	# Linux SSH-Key- and User-Management (LSKUM)<br>
	<? echo $GLOBALS['sudousr']; ?>            ALL=NOPASSWD: /usr/sbin/useradd -m * -p *<br>
        <? echo $GLOBALS['sudousr']; ?>            ALL=NOPASSWD: /bin/cp /home/itcsskm/authorized_keys_rollout */.ssh/authorized_keys <br>
	<? echo $GLOBALS['sudousr']; ?>            ALL= (ALL) NOPASSWD: /bin/mkdir /home/*/.ssh <br>
	</b>

        <br>
        3) The SSH pub key must be added:<br> 
        LSKUMsrv $> copy the pub key <b> <? echo $sudoident ?>.pub</b><br>
	newHOST $> to <b>/home/<? echo $GLOBALS['sudousr']; ?>/.ssh/authorized_keys</b><br>
        <br>
        4) The Host key of the remote server must be added: <br>
        newHOST $> copy the output of <b>'/etc/ssh/ssh_host_rsa_key.pub'</b><br>
        LSKUMsrv $> edit <b>/etc/ssh/ssh_known_hosts</b> and add in a new empty line:<br>
        'Hostname of newHOST' [then paste copied entry] <br><br>
        ALL these requirements must be met and are necessary only once! <br>
        You should integrate the steps above into your initial server setup.<br>
        Only proceed when all the above steps are done.<br><br>
	Optional: add the following to your /etc/sudoers for enabling backups via BackupPC:<br>
	<b>
	# Enabling the use of BackupPC software: <br>
	backuppc(or the user you want to use)        ALL=NOPASSWD: /usr/bin/rsync --server *
	</b><br><br>	
        </i></font>
	<?

    if(empty($nr)) {
      echo("<tr><td class='detail1'>No Account found. You have to create one under \"Accounts\" first</td><td class='detail2'></td></tr>\n");
    }
    else {
      while( $row = mysql_fetch_array( $result )) 
      {
        // Afecting values
        $name = $row["name"];
        $id = $row["id"];
     	
        // displaying rows
        echo("<tr>\n");
	echo("  <td class='detail1'><img src='images/mister.gif'>$name</td>\n");
	//CHANGED BY TFISCHER TO FIX ROOT USER ISSUE
	echo("  <td class='detail1'><a href='decrypt_key.php?action=createaccount_action&name=$name'><img src=\"images/edit.gif\" border=0 alt=\"Edit\"></a></td>\n");
	echo("</tr>\n");
      }
      mysql_free_result( $result );
    }
  ?>
  </fieldset>

<? end_right_pane(); ?>
<? end_main_frame(); ?>

  
</body>
</html>
<?
} 
?>

