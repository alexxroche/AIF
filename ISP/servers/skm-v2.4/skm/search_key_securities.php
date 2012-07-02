<?php include('MyFunctions.inc.php');

if (isset($_GET["key"])) $id_key = $_GET["key"]; else $id_key = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";

// We get the list of keyrings
//$result = mysql_query( "SELECT * FROM `keyrings`" );


if($step != '1')
{
?>


<html>
<HEAD>
<TITLE>Key Security Search</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="search_key_securities" action="search_key_securities.php" method="post">
    <fieldset><legend>Select a key </legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><img src='images/key_little.gif'><?php display_availables_keys(); ?></td>
        </td>
      </tr>
    </table>
    </fieldset>
      <center>
      <input name="step" type="hidden" value="1">
      <input name="submit" type="submit" value="Search">
      </center>
    </form>
    </center>

<? end_right_pane(); ?>
<? end_main_frame(); ?>


</body>
</html>

<?php
}
else
{?>
<html>
<HEAD>
<TITLE>Key Security Search</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); 


// We will seek all accounts of the servers...
$result = mysql_query( "SELECT * FROM `hak` ORDER BY `id_host`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");

$nr = mysql_num_rows( $result );
if(empty($nr))
{
    echo("<fieldset><legend>Error</legend>This keyring does not seem to be in use...</fieldset>\n");
} else {

    $id_lasthost="";
    $id_lastaccount="";

    $key_name = get_key_name($id_key); 
    echo("<fieldset><legend>Searching securities for key $key_name</legend>\n");
    echo("<table class='detail'>\n");

    while( $row = mysql_fetch_array( $result ))
    {
	$line=""; 
	// We start by seeing if the key exists
        $id_currentkey = $row["id_key"];
	if ( $id_currentkey == $id_key )
        {

	  // HOST DISPLAY
	  $id_currenthost = $row["id_host"];
	  if ( $id_currenthost != $id_lasthost )
          {
		$hostname = get_host_name($id_currenthost);
		$line="<tr><td class='title'><img src='images/server.gif' border='0'>$hostname</td></tr>\n";
		$id_lastaccount = "";
          }
		$id_lasthost = $id_currenthost;
                

         
	  // ACCOUNT DISPLAY 
	  $id_currentaccount = $row["id_account"];
	  if ( $id_currentaccount != $id_lastaccount )
          {
		$accountname = get_account_name($id_currentaccount);
		$line.="<tr><td class='detail1'><img src='images/mister.gif' border='0'>$accountname</td></tr>\n";
	  }
		$id_lastaccount = $id_currentaccount;


	  $keyname = get_key_name($id_currentkey);
	  $line.="<tr><td class='detail2'><img src='images/key_little.gif' border='0'>$keyname</td></tr>\n";
	  echo("$line\n");

        } 

    }
    echo("</table></fieldset>\n");
}

// We will seek all accounts of the Servers that contain the keyring application...
// ---------------------------------------------------------------------------------------

$resultkeyring = mysql_query( "SELECT * FROM `keyrings-keys` where `id_key` = '$id_key' ORDER BY `id_keyring`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");

while ( $rowkeyring = mysql_fetch_array( $resultkeyring ))
{
	$id_keyring = $rowkeyring["id_keyring"];

	$result = mysql_query( "SELECT * FROM `hak` where `id_keyring` = '$id_keyring' ORDER BY `id_host`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");

	$keyring_name = get_keyring_name($id_keyring); 
	$nr = mysql_num_rows( $result );
	if(empty($nr))
	{
    	echo("<fieldset><legend>Error</legend>This keyring does not seem to be in use...</fieldset>\n");
	} else {

    		$lasthostname="";

    		echo("<fieldset><legend>Searching securities for keyring $keyring_name</legend>\n");
    		echo("<table class='detail'>\n");
    		while( $row = mysql_fetch_array( $result ))
    		{
			echo("<tr>\n");
        		// Afecting values
        		$id_host = $row["id_host"];
        		$id_account = $row["id_account"];

        		$hostname = get_host_name($id_host);
			if ( $hostname != $lasthostname )
        		{
				echo("<tr><td class='title'><img src='images/server.gif' border='0'>$hostname</td></tr>\n");
				$lasthostname = $hostname;
			}
        		$account_name = get_account_name($id_account);
			echo("<tr><td class='detail2'><img src='images/mister.gif' border=0>$account_name</td></tr>\n");

    		}
    		echo("</table></fieldset>\n");
	}
}
echo("<center><a href='search_key_securities.php'>Click here for a new search</a></center>\n");
end_right_pane();
end_main_frame();

}
?>

</body>
</html>
