<?php
include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";

if( empty($id) )
{

?>
<html>
<head>
  <title>Keys List</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

   <fieldset><legend>Keys <a href="keys_setup.php">[add a key]<img src='images/add.gif' border='0'></a></legend>
  
   <table class='detail'>

    <?php
    $result = mysql_query( "SELECT * FROM `keys` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='detail1'>No key found</td></tr>\n");
    }
    else {
      while( $row = mysql_fetch_array( $result )) 
      {
        // Afecting values
        $name = $row["name"];
        $id = $row["id"];
      
        // displaying rows
        echo("  <tr wdith='100%'>\n");
        echo("    <td width='90%' class='detail1'><img src='images/key_little.gif' border=0'>$name\n");
        echo("[ <a href='keys_setup.php?id=$id'>Edit name</a> ");
	// prevent deletion of key 1 (SKM Key)
	if ($id > 1)
	{
	  echo("| <a href='keys.php?id=$id&action=delete'>Delete</a> ]</td>\n");
	}
	else
	{
	  echo("]");
	}
        echo("  </tr>");
      }
      echo("</table>\n");
      mysql_free_result( $result );
    }
  
    //print("<a href=\"keys_setup.php\">Click here to add a key</a><img src='images/add.gif' border='0'>");?>
  </fieldset>

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
    mysql_query( "DELETE FROM `keys` WHERE `id`='$id'" );
	mysql_query( "DELETE FROM `keyrings-keys` WHERE `id_key`='$id'" );
    // Let's go back to where we came from
    header("Location:keys.php");
    exit ();
  }
}
?>

