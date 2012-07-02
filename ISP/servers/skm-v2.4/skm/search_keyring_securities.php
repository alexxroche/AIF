<?php include('MyFunctions.inc.php');

if (isset($_GET["keyring"])) $id_keyring = $_GET["keyring"]; else $id_keyring = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";

// We get the list of keyrings
$result = mysql_query( "SELECT * FROM `keyrings`" );


if($step != '1')
{
?>


<html>
<HEAD>
<TITLE>Keyring Security Search</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>

    <center>
    <form name="search_keyring_securities" action="search_keyring_securities.php" method="post">
    <fieldset><legend>Select a keyring </legend>
    <table border='0' align='center' class="modif_contact">
      <tr>
        <td class="Type"><img src='images/keyring_little.gif'><?php display_availables_keyrings(); ?></td>
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
<TITLE>Keyring Security Search</TITLE>
<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</HEAD>
<BODY>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); 
// We will seek all accounts of the servers that contain the keyring application ...

$result = mysql_query( "SELECT * FROM `hak` where `id_keyring` = '$id_keyring' ORDER BY `id_host`" )
                         or die (mysql_error()."<br>Couldn't execute query: $query");

$keyring_name = get_keyring_name($id_keyring); 
$nr = mysql_num_rows( $result );
if(empty($nr))
{
    echo("<fieldset><legend>Error</legend>This keyring does not seem to be in use...</fieldset>\n");
} else {

    $lasthostname="";

    echo("<fieldset><legend>Seaching securities for keyring $keyring_name</legend>\n");
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
    echo("</fieldset>\n");
}

echo("<center><a href='skm/search_keyring_securities.php'>Click here for a new search</a></center>\n");
end_right_pane();
end_main_frame();

}
?>

</body>
</html>
