<?php
include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";

if( empty($id) )
{

?>
<html>
<head>
  <title>Group List</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

   <fieldset><legend>Groups <a href="groups_setup.php">[add a group]<img src='images/add.gif' border='0'></a></legend>
  
   <table class='detail'>

    <?php
    $result = mysql_query( "SELECT * FROM `groups` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='detail1'>No group found</td><td class='detail2'></td></tr>\n");
    }
    else {
      while( $row = mysql_fetch_array( $result )) 
      {
        // Afecting values
        $name = $row["name"];
        $id = $row["id"];
      
        // displaying rows
        echo("  <tr wdith='100%'>\n");
        echo("    <td width='90%' class='detail1'>$name</td>\n");
        echo("    <td width='10%' class='detail1'><a href='groups_setup.php?id=$id'><img src=\"images/edit.gif\" border=0 alt=\"Edit\"></a><a href='groups.php?id=$id&action=delete'><img src=\"images/delete.gif\" border=0 alt=\"Delete\"></a></td>\n");
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
    mysql_query( "DELETE FROM `groups` WHERE `id`='$id'" );
    // Let's go back to the Reminder List page
    header("Location:groups.php");
    exit ();
  }
}
?>

