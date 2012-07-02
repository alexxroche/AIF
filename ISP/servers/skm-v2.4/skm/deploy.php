<?php
include('MyFunctions.inc.php');

$id = $_GET['id'];

if( empty($id) )
{

?>


<html>
<head>
  <title>Deployment list</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

  <fieldset><legend>Host List </legend>

  <table class='detail'>
  
    <?php

    $result = mysql_query( "SELECT * FROM `hosts` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='detail1'>No host to deploy</td><td class='detail2'></td></tr>\n");
    }
    else {
      while( $row = mysql_fetch_array( $result )) 
      {
        // Afecting values
        $name = $row["name"];
        $id = $row["id"];
      
        // displaying rows
	echo("<tr>\n");

	// display expand button if expand=N
	if ($row['expand'] == "N") {
        	//echo("  <td class='title'><img src='images/server.gif' border='0'>$name <a href=\"deploy.php?id=$id&action=expand\">[expand |</a><a href=\"deploy.php?id=$id&action=deploy_host\">Deploy]</a></td>\n");
        	echo("  <td class='title'><img src='images/server.gif' border='0'>$name <a href=\"deploy.php?id=$id&action=expand\">[expand]</a></td>\n");
	} else {
        	//echo("  <td class='title'><img src='images/server.gif' border='0'>$name <a href=\"deploy.php?id=$id&action=collapse\">[collapse |</a><a href=\"deploy.php?id=$id&action=deploy_host\">Deploy]</a></td>\n");
        	echo("  <td class='title'><img src='images/server.gif' border='0'>$name <a href=\"deploy.php?id=$id&action=collapse\">[collapse]</a></td>\n");
	}
	//No need for the "delete" icon
	//echo("  <td class='title'><a href='hosts_setup.php?id=$id'><img src=\"images/edit.gif\" border=0 alt=\"Edit\"></a><a href='deploy.php?id=$id&action=delete'><img src=\"images/delete.gif\" border=0 alt=\"Delete\"></a></td>\n");
	echo("</tr>\n");


	// DISPLAY DETAILS ONLY IF EXPAND=Y
	if ($row['expand'] == "Y" )
        {

        // looking for accounts
	// --------------------
        $accounts = mysql_query( "SELECT * FROM `hosts-accounts` WHERE `id_host` = '$id'" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
        $nr_accounts = mysql_num_rows( $accounts );
        if(empty($nr_accounts)) {
          echo ("<tr><td class='detail2'>No account to deploy</td><td class='detail2'></td></tr>\n");
	} else {
	  while ( $keyrow = mysql_fetch_array($accounts))
	  {
	        // Afecting values
	        //$name = $keyrow["name"];
	    	$id_account = $keyrow["id_account"];
            	$name_account = get_account_name($id_account);

	    	// Displaying rows
            	echo("<tr>\n");
		echo("  <td class='detail2'><img src='images/mister.gif' border=0>$name_account <a href=\"decrypt_key.php?action=deploy_account&id=$id&id_account=$id_account\">[Deploy]</a></td>\n");
		//No need for "Deleted" icon
		//echo("  <td class='detail2'><a href='deploy.php?id=$id&id_account=$id_account&action=deleteAccount'><img src=\"images/delete.gif\" border=0 alt=\"Delete\"></a></td>\n");
		echo("</tr>\n");

		// looking for keyrings
		//---------------------
        	$keyrings = mysql_query( "SELECT * FROM `hak` WHERE `id_host` = '$id' and `id_account` ='$id_account'" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
        	$nr_keyrings = mysql_num_rows( $keyrings );
        	if(empty($nr_keyrings)) {
          		echo ("<tr><td class='detail3'>No keyrings associated</td><td class='detail2'></td></tr>>\n");
		} else {
	  		while ( $keyringrow = mysql_fetch_array($keyrings))
	  		{
	    			// Afecting values
	    			$id_keyring = $keyringrow["id_keyring"];
            			$name_keyring = get_keyring_name($id_keyring);

	    			// Displaying rows
				echo("<tr>\n");
            			echo("  <td class='detail3'><img src='images/keyring_little.gif' border='0'>$name_keyring</td>\n");
				echo("</tr>\n");
			}
			mysql_free_result ( $keyrings );
		}

	  }
	  mysql_free_result( $accounts );
	} 
        //echo ("<tr><td class='detail2'><a href=\"ha_setup.php?id=$id&host_name=$name=\">Click here to add account(s) to $name</a><img src='images/add.gif' border='0'></td></tr>\n");
      }
      } // END EXPAND
      mysql_free_result( $result );
    }
    ?>
  
      <?//print("<tr><td class='detail1'><a href=\"hosts_setup.php\">Click here to create a host</a><img src='images/add.gif' border='0'></td></tr>");?>
  
</td></tr></table>

<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>

  <?php
}
else
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
  if ( $_GET['action'] == "expand" )
  {
    $id = $_GET['id'];
    mysql_query( "UPDATE `hosts` SET `expand` = 'Y' WHERE `id`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapse" )
  {
    $id = $_GET['id'];
    mysql_query( "UPDATE `hosts` SET `expand` = 'N' WHERE `id`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }

  header("Location:deploy.php");
  echo ("hosts Deleted, redirecting...");
  exit ();
}
?>

