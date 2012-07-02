<?php
include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_GET["action"])) $action = $_GET["action"]; else $action = "";
if (isset($_GET["id_hostgroup"])) $id_hostgroup = $_GET["id_hostgroup"]; else $id_hostgroup = "";
if (empty($action))
{ 
?>

<html>
<head>
  <title>SKM - Display Host Details</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>
<?php
  
      $result = mysql_query( "SELECT * FROM `hosts` where `id_group` = '$id_hostgroup' AND `id`='$id'" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
      $nr = mysql_num_rows( $result );
      $row = mysql_fetch_array( $result ); 
      // Afecting values
      $name = $row["name"];
      $id = $row["id"];
      
      // getting the right icon
	$icon="images/server.gif";
	if ( $row['ostype'] == "RHEL" ) $icon="images/icon-redhat.gif";
	if ( $row['ostype'] == "AIX" ) $icon="images/icon-aix.gif";
	if ( $row['ostype'] == "Solaris" ) $icon="images/icon-solaris.gif";
	if ( $row['ostype'] == "Windows" ) $icon="images/icon-windows.gif";
	if ( $row['ostype'] == "FreeBSD" ) $icon="images/icon-freebsd.gif";

  $ostype=$row['ostype'];
  $osvers=$row['osvers'];
  $model=$row['model'];
  $po=$row['provider'];
  $serialno=$row['serialno'];
  $groupname=get_group_name($id_hostgroup);

  echo("<table>");
  echo("	<caption>$name - Information</caption>\n");
  echo("	<tr><td>OS Type : <img src='$icon' border='0'> $ostype version $osvers, hostgroup : <a href='hosts-view.php?id_hostgroup=$id_hostgroup'>$groupname</a></td></tr>\n");
  echo("	<tr><td>Provider : $po , model : $model ( SR# : $serialno )</td></tr>\n");
  echo("</table>\n");

  echo("<table>");
  echo("<tr>");
  echo("	<th><a href='hosts_setup.php?id=$id&id_hostgroup=$id_hostgroup'>Click here to edit $name details</a></th>\n");
  echo("	<th><a href='host-view.php?id=$id&action=delete&id_hostgroup=$id_hostgroup'>Click here to delete $name</a></th>\n");
  echo("</tr></table>\n");

  echo("<table>\n");
  echo("	<caption>ssh key management</caption>\n");
  echo("	<th><a href=\"ha_setup.php?id=$id&host_name=$name&id_hostgroup=$id_hostgroup\">Click here to manage a new unix account on $name</a></th>\n");
  echo("</tr></table>\n");
	
  echo("<table class='detail'>\n");

        // looking for accounts
	// --------------------
        $accounts = mysql_query( "SELECT * FROM `hosts-accounts` WHERE `id_host` = '$id'" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
        $nr_accounts = mysql_num_rows( $accounts );
        if(empty($nr_accounts)) {
          echo ("<tr><td class='detail2'>No accounts associated</td></tr>\n");
	} else {
	  while ( $keyrow = mysql_fetch_array($accounts))
	  {
	        // Afecting values
	        //$name = $keyrow["name"];
	    	$id_account = $keyrow["id_account"];
            	$name_account = get_account_name($id_account);
                $display_account = $keyrow["expand"];

                if ( $display_account == "N" )
                {
                        // Displaying rows
                        echo("<tr>\n");
                        echo("  <td class='detail2'><a href=\"host-view.php?id=$id&id_hostgroup=$id_hostgroup&action=expandaccount&account_id=$id_account\"><img src='images/expand.gif' border='0'></a><img src='images/mister.gif' border=0>$name_account <a href=\"hak_setup.php?id=$id&host_name=$name&id_account=$id_account&account_name=$name_account&id_hostgroup=$id_hostgroup\">[add a keyring | </a><a href=\"hakk_setup.php?id=$id&host_name=$name&id_account=$id_account&account_name=$name_account&id_hostgroup=$id_hostgroup\">add a key | </a><a href=\"decrypt_key.php?action=deploy_account&id=$id&id_account=$id_account&id_hostgroup=$id_hostgroup\">Deploy |</a><a href=\"view_aut_account.php?id=$id&id_account=$id_account&id_hostgroup=$id_hostgroup\"> View Auth </a>\n");
                        echo("<a href='host-view.php?id=$id&id_account=$id_account&action=deleteAccount&id_hostgroup=$id_hostgroup'>| Delete ]</a></td>\n");
                        echo("</tr>\n");
                } else {
            		echo("<tr>\n");
			echo("  <td class='detail2'><a href=\"host-view.php?id=$id&id_hostgroup=$id_hostgroup&action=collapseaccount&account_id=$id_account\"><img src='images/collapse.gif' border='0'></a><img src='images/mister.gif' border=0>$name_account <a href=\"hak_setup.php?id=$id&host_name=$name&id_account=$id_account&account_name=$name_account&id_hostgroup=$id_hostgroup\">[add a keyring | </a><a href=\"hakk_setup.php?id=$id&host_name=$name&id_account=$id_account&account_name=$name_account&id_hostgroup=$id_hostgroup\">add a key | </a><a href=\"decrypt_key.php?action=deploy_account&id=$id&id_account=$id_account&id_hostgroup=$id_hostgroup\">Deploy |</a><a href=\"view_aut_account.php?id=$id&id_account=$id_account&id_hostgroup=$id_hostgroup\"> View Auth </a>\n");
			echo("<a href='host-view.php?id=$id&id_account=$id_account&action=deleteAccount&id_hostgroup=$id_hostgroup'>| Delete ]</a></td>\n");
			echo("</tr>\n");


			// looking for keyrings and keys
			//------------------------------
        		$keyrings = mysql_query( "SELECT * FROM `hak` WHERE `id_host` = '$id' and `id_account` ='$id_account' and `id_keyring` != '0' " ) or die (mysql_error()."<br>Couldn't execute query: $query");
        		$nr_keyrings = mysql_num_rows( $keyrings );
        		$keys = mysql_query( "SELECT * FROM `hak` WHERE `id_host` = '$id' and `id_account` ='$id_account' and `id_key` != '0' " ) or die (mysql_error()."<br>Couldn't execute query: $query");
        		$nr_keys = mysql_num_rows( $keys );

			// if no key nor keyring found
			if(empty($nr_keys) and empty($nr_keyrings))
			{
        	 		echo ("<tr><td class='detail3'>No keys or keyrings associated</td></tr>\n");
			} //if(empty($nr_keys) and empty($nr_keyrings))

			// if keyring found
        		if(!empty($nr_keyrings)) {
	  			while ( $keyringrow = mysql_fetch_array($keyrings))
	  			{
					display_keyring($keyringrow["id_host"],$keyringrow["id_account"],$keyringrow["id_keyring"],$id_hostgroup,"detail4",$keyringrow["expand"]);
				} //while ( $keyringrow = mysql_fetch_array($keyrings))
				mysql_free_result ( $keyrings );
			} //if(!empty($nr_keyrings))

			// if key found
        		if(!empty($nr_keys)) {
	  			while ( $keyrow = mysql_fetch_array($keys))
	  			{
					display_key($keyrow["id_host"],$keyrow["id_account"],$keyrow["id_key"],$id_hostgroup,"detail3");
	
				} //while ( $keyrow = mysql_fetch_array($keys))
				mysql_free_result ( $keys );
			} //if(!empty($nr_keys)) 
		} //if ( $display_account == "N" )
	  } //while( $keyrow = mysql_fetch_array($accounts))
	  mysql_free_result( $accounts );
	} //if(empty($nr_accounts))
  
?>  
</td></tr></table>

<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>

  <?php
}
else //( empty($action))
{
  if ( $_GET['action'] == "delete" )
  {
    $id = $_GET['id'];
    mysql_query( "DELETE FROM `hosts` WHERE `id`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    mysql_query( "DELETE FROM `hosts-accounts` WHERE `id_host`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    mysql_query( "DELETE FROM `hak` WHERE `id_host`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    header("Location:hosts-view.php?id_hostgroup=$id_hostgroup");
    exit ();
  }
  if ( $_GET['action'] == "deleteAccount" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['id_account'];
    mysql_query( "DELETE FROM `hak` WHERE `id_host`='$id' and `id_account`='$id_account'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    mysql_query( "DELETE FROM `hosts-accounts` WHERE `id_host`='$id' and `id_account`='$id_account'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }

  if ( $_GET['action'] == "deleteKeyring" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['id_account'];
    $id_keyring = $_GET['id_keyring'];
    mysql_query( "DELETE FROM `hak` WHERE `id_host`='$id' and `id_account`='$id_account' and `id_keyring`='$id_keyring'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "deleteKey" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['id_account'];
    $id_key = $_GET['id_key'];
    mysql_query( "DELETE FROM `hak` WHERE `id_host`='$id' and `id_account`='$id_account' and `id_key`='$id_key'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "expand" )
  {
    $id = $_GET['id'];
    mysql_query( "UPDATE `hosts` SET `expand` = 'Y' WHERE `id`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "expandkeyring" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['account_id'];
    $id_keyring = $_GET['keyring_id'];
    mysql_query( "UPDATE `hak` SET `expand` = 'Y' WHERE `id_host`='$id' and `id_account`='$id_account' and `id_keyring`='$id_keyring'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapsekeyring" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['account_id'];
    $id_keyring = $_GET['keyring_id'];
    mysql_query( "UPDATE `hak` SET `expand` = 'N' WHERE `id_host`='$id' and `id_account`='$id_account' and `id_keyring`='$id_keyring'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "expandaccount" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['account_id'];
    mysql_query( "UPDATE `hosts-accounts` SET `expand` = 'Y' WHERE `id_host`='$id' and `id_account`='$id_account'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapseaccount" )
  {
    $id = $_GET['id'];
    $id_account = $_GET['account_id'];
    mysql_query( "UPDATE `hosts-accounts` SET `expand` = 'N' WHERE `id_host`='$id' and `id_account`='$id_account'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "expandall" )
  {
    mysql_query( "UPDATE `hosts` SET `expand` = 'Y' WHERE `id_group` = '$id_hostgroup'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    # Ajout le 02-02-2006 : Pour expand all on veut egalement etendre les comptes
    mysql_query( "UPDATE `hosts-accounts` SET `expand` = 'Y'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    # Ajout le 02-02-2006 : Pour expand all on veut egalement etendre les keyrings....
    mysql_query( "UPDATE `hak` SET `expand` = 'Y'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapse" )
  {
    $id = $_GET['id'];
    mysql_query( "UPDATE `hosts` SET `expand` = 'N' WHERE `id`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapseall" )
  {
    mysql_query( "UPDATE `hosts` SET `expand` = 'N' WHERE `id_group` = '$id_hostgroup'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    # Ajout le 02-02-2006 : Pour expand all on veut egalement etendre les comptes
    mysql_query( "UPDATE `hosts-accounts` SET `expand` = 'N'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    # Ajout le 02-02-2006 : Pour expand all on veut egalement etendre les keyrings....
    mysql_query( "UPDATE `hak` SET `expand` = 'N'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }


  header("Location:host-view.php?id_hostgroup=$id_hostgroup&id=$id");
  exit ();
} //( empty($action))
?>

