<?php
include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_GET["id_key"])) $id_key = $_GET["id_key"]; else $id_key = "";
if (isset($_GET["action"])) $action = $_GET["action"]; else $action = "";

if( empty($id) and empty($action) )
{

?>


<html>
<head>
  <title>Keyring list</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

  <fieldset><legend>Keyring List <a href="keyrings_setup.php">[create a new keyring |</a><a href="keyrings.php?action=expandall">Expand all |</a><a href="keyrings.php?action=collapseall">Collapse all ]</a></legend>

  <table class='detail'>
  
    <?php

    $result = mysql_query( "SELECT * FROM `keyrings` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='detail1'>No keyring defined</td></tr>\n");
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
		echo("  <td class='title'><a href=\"keyrings.php?id=$id&action=expand\"><img src='images/expand.gif' border=0\"></a><img src='images/keyring_little.gif'>$name <a href=\"kk_setup.php?id=$id&keyring_name=$name\">[ add a key</a>\n");
	} else {
		echo("  <td class='title'><a href=\"keyrings.php?id=$id&action=collapse\"><img src='images/collapse.gif' border=0\"></a><img src='images/keyring_little.gif'>$name <a href=\"kk_setup.php?id=$id&keyring_name=$name\">[ add a key</a>\n");
	}

        echo("<a href='keyrings_setup.php?id=$id'>| edit name</a><a href='keyrings.php?id=$id&action=delete'>| Delete ]</a>\n");
	echo("<tr>\n");

        // DISPLAY DETAILS ONLY IF EXPAND=Y
        if ($row['expand'] == "Y" )
        {


        	// looking for keys
        	$keys = mysql_query( "SELECT * FROM `keyrings-keys` WHERE `id_keyring` = '$id'" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
        	$nr_keys = mysql_num_rows( $keys );
        	if(empty($nr_keys)) {
          	echo ("<tr><td class='detail2'>No keys associated</td></tr>\n");
		} else {
	  	while ( $keyrow = mysql_fetch_array($keys))
	  	{
	    	// Afecting values
	    	//$name = $keyrow["name"];
	    	$id_key = $keyrow["id_key"];
            	$name_key = get_key_name($id_key);

	    	// Displaying rows
	    	echo("<tr>\n");
	    	echo("  <td class='detail2'><img src='images/key_little.gif' border=0 >$name_key\n");
            	echo("<a href='keyrings.php?id=$id&id_key=$id_key&action=deleteJT'>[ Delete ]</a></td>\n");
	    	echo("</tr>\n");
	  	}
	  	mysql_free_result( $keys );
		} 
        	//echo ("<tr><td class='detail2'><br><a href=\"kk_setup.php?id=$id&keyring_name=$name\">Click here to add key(s) to $name</a><img src='images/add.gif' border='0'></td></tr>\n");
      	} //END expand
      }
      mysql_free_result( $result );
    }
    ?>
  
    <?//print("<tr><td class='detail1'><a href=\"keyrings_setup.php\">Click here to create a keyring</a><img src='images/add.gif' border='0'></td></tr>\n");?>
    </table>
  
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
    mysql_query( "DELETE FROM `keyrings` WHERE `id`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
    
    mysql_query( "DELETE FROM `keyrings-keys` WHERE `id_keyring`='$id'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }

  if ( $_GET['action'] == "deleteJT" )
  {
    mysql_query( "DELETE FROM `keyrings-keys` WHERE `id_keyring`='$id' and `id_key`='$id_key'" )
		or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "expand" )
  {
    $id = $_GET['id'];
    mysql_query( "UPDATE `keyrings` SET `expand` = 'Y' WHERE `id`='$id'" )
                or die (mysql_error()."<br>Couldn't execute query: $query");
  }

  if ( $_GET['action'] == "expandall" )
  {
    mysql_query( "UPDATE `keyrings` SET `expand` = 'Y'" )
                or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapse" )
  {
    $id = $_GET['id'];
    mysql_query( "UPDATE `keyrings` SET `expand` = 'N' WHERE `id`='$id'" )
                or die (mysql_error()."<br>Couldn't execute query: $query");
  }
  if ( $_GET['action'] == "collapseall" )
  {
    mysql_query( "UPDATE `keyrings` SET `expand` = 'N'" )
                or die (mysql_error()."<br>Couldn't execute query: $query");
  }

  // Let's go back to the Reminder List page
  header("Location:keyrings.php");
  echo ("keyrings Deleted, redirecting...");
  exit ();
}
?>

