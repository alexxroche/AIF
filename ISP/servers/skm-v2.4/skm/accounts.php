<?php
include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";

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

   <fieldset><legend>Accounts <a href="accounts_setup.php">[create a new account]<img src='images/add.gif' border='0'></a></legend>

   <table class='detail'>
  
    <?php

    $result = mysql_query( "SELECT * FROM `accounts` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='detail1'>No Account found</td><td class='detail2'></td></tr>\n");
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
	echo("  <td class='detail1'>");
	// editing & deletion of root account (id 1) is not allowed
	if($id > 1)
	{
	  echo("<a href='accounts_setup.php?id=$id'><img src=\"images/edit.gif\" border=0 alt=\"Edit\"></a> <a href='accounts.php?id=$id&action=delete'><img src=\"images/delete.gif\" border=0 alt=\"Delete\"></a>");
	}
	echo("</td>\n");
	echo("</tr>\n");
      }
      mysql_free_result( $result );
    }
  
    //print("<a href=\"accounts_setup.php\">Click here to add an account</a><img src='images/add.gif' border='0'>");?>
  </fieldset>

<? end_right_pane(); ?>
<? end_main_frame(); ?>

  
</body>
</html>

  <?php
}
else
{
  // deletion of root account (id 1) is not allowed
  if (($_GET['action'] == "delete") && ($id > 1))
  {
    mysql_query( "DELETE FROM `accounts` WHERE `id`='$id'" );
    mysql_query( "DELETE FROM `hosts-accounts` WHERE `id-account`='$id'" );
    // Let's go back to the Reminder List page
    header("Location:accounts.php");
    echo ("account deleted, redirecting...");
    exit ();
  }
}
?>