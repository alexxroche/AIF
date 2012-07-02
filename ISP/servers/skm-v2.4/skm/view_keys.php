<?php
include('MyFunctions.inc.php');

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

   <table class='detail'>

    <?php
    $result = mysql_query( "SELECT * FROM `keys` ORDER BY `name`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");
    
    $nr = mysql_num_rows( $result );
    if(empty($nr)) {
      echo("<tr><td class='title'>No key found</td><td class='detail2'></td></tr>\n");
    }
    else {
      // To display a different color on each row
      $counter = 1;
      while( $row = mysql_fetch_array( $result )) 
      {
        // Afecting values
        $name = $row["name"];
        $id = $row["id"];
	$key_value = $row["key"];
      
        // displaying rows
	if ( $counter == 2 ) { $style = "detail1"; $counter = 1; } else { $style = "title"; $counter++; }
        echo("  <tr width='100%'><td class='$style'><img src='images/key_little.gif' border=0'>$name : $key_value</td></tr>\n");
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

