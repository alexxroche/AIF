<?php
include('MyFunctions.inc.php');

if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";

if( empty($id) )
{

?>
<html>
<head>
  <title>Global File List</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

   <fieldset><legend>Global File(s) <a href="globalfile_setup.php">[ add a new one ]</legend>
  
   <table class='detail'>

    <?php
    $result = mysql_query( "SELECT * FROM `globalfiles` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='detail1'>No global file found</td></tr>\n");
    }
    else {
      while( $row = mysql_fetch_array( $result )) 
      {
        // Afecting values
        $name = $row["name"];
        $id = $row["id"];
      
        // displaying rows
        echo("  <tr wdith='100%'>\n");
        echo("    <td width='90%' class='detail1'><img src='images/globalfile.gif' border=0'>$name\n");
        echo("<a href='globalfile_setup.php?id=$id'>[ Edit </a><a href='globalfile.php?id=$id&action=delete'>| Delete </a><a href='decrypt_key.php?id=$id&action=deploy_gfile'>| Deploy ]</a></td>\n");
        echo("  </tr>");
      }
      echo("</table>\n");
      mysql_free_result( $result );
    }
  
  echo("</fieldset><br>\n");

 end_right_pane(); 
 end_main_frame(); 

?>
</body>
</html>

  <?php
}
else
{
  if ( $_GET['action'] == "delete" )
  {
    mysql_query( "DELETE FROM `globalfiles` WHERE `id`='$id'" );
    header("Location:globalfile.php");
    exit ();
  }
}
?>

