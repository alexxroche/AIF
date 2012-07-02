<?php
include('MyFunctions.inc.php');

if (isset($_GET["action"])) $action = $_GET["action"]; else $action = "";
if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
if (isset($_GET["id_account"])) $id_account = $_GET["id_account"]; else $id_account = "";
if (isset($_GET["id_gfile"])) $id_gfile = $_GET["id_gfile"]; else $id_gfile = "";
if (isset($_GET["id_keyring"])) $id_keyring = $_GET["id_keyring"]; else $id_keyring = "";
if (isset($_GET["id_key"])) $id_key = $_GET["id_key"]; else $id_key = "";
if (isset($_GET["id_hostgroup"])) $id_hostgroup = $_GET["id_hostgroup"]; else $id_hostgroup = "";
if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";


if ( empty( $step ) )
{
?>

<html>
<head>
  <title>Decrypting key</title>
  <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
</head>
<body>

<?php start_main_frame(); ?>
<?php start_left_pane(); ?>
<?php display_menu(); ?>
<?php end_left_pane(); ?>
<?php start_right_pane(); ?>


  <center>
  <br>
  <form action="decrypt_key.php" method="Post">

  <table class="login" align='left' width='200px'>
    <tr>
      <td class='line' colspan='2'>
	<img src='images/encrypted.gif'><br><br>
	<!-- CHANGED BY TFISCHER FOR BETTER UNDERSTANDING -->
	The local SKM SSH Private key is encrypted (if not do it before proceed)<br>
	Please provide the passphrase (usually this is a PGP encryption key):<br>
	<input type="password" name="psPassword"><br>
      </td>
    </tr><tr>
      <td class='line' colspan='2'><br><input type="submit" value="Continue"><br></td>
    </tr>
  </table>

  <input type="hidden" name="step" value="1">
  <input type="hidden" name="id" value="<?php echo("$id"); ?>">
  <input type="hidden" name="id_account" value="<?php echo("$id_account"); ?>">
  <input type="hidden" name="id_hostgroup" value="<?php echo("$id_hostgroup"); ?>">
  <input type="hidden" name="id_keyring" value="<?php echo("$id_keyring"); ?>">
  <input type="hidden" name="id_key" value="<?php echo("$id_key"); ?>">
  <input type="hidden" name="action" value="<?php echo("$action"); ?>">
  </form>

<?php end_right_pane(); ?>
<?php end_main_frame(); ?>


</body>
</html>

<?php
} else {
	// Decrypting key
	$passwd = $_POST['psPassword'];
	$id = $_POST['id'];
	$id_account = $_POST['id_account'];
	$id_hostgroup = $_POST['id_hostgroup'];
	$id_keyring = $_POST['id_keyring'];
	$id_key = $_POST['id_key'];
	$action = $_POST['action'];

	// Validating password
	$sResult = mysql_query( "Select * from `security` where `password` = MD5('$passwd')" ) 
		or die (mysql_error()."<br>Couldn't execute query: $query");
	$sNumRow = mysql_num_rows( $sResult );

    	if (empty($sNumRow)) {
      		header("location:incorrect_key.php");
		
    	} else {
		// gpg --gen-key, then we enter Apache as user. The homedir is defined in config.inc.php
		// we encrypt the file with gpg --encrypt $home_of_webserver_account/.ssh/id_rsa and we select user Apache

		// We decrypt the key
		$output = shell_exec("echo \"$passwd\" | ".$gpgbin." -v --batch --homedir ".$home_of_webserver_account."/.gnupg -u Apache -o ".$home_of_webserver_account."/.ssh/id_rsa --passphrase-fd 0 --decrypt ".$home_of_webserver_account."/.ssh/id_rsa.gpg 2>&1");
		// we change permission on the file
		$output .= shell_exec("chmod 600 ".$home_of_webserver_account."/.ssh/id_rsa");
	
        $pos = strstr($output,'failed');
		$pos = strstr($output,'No such file or directory');

        	if ( $pos === false ) {
                	$output .= "Decryption successfull";
        	} else {
			header("location:decrypt_key.php?action=deploy_account&id=$id&id_account=$id_account&id_hostgroup=$id_hostgroup");
        	}


		if ( $action == "deploy_account" ){
			header("location:$action.php?id=$id&id_account=$id_account&id_hostgroup=$id_hostgroup");
		}
		if ( $action == "deploy_gfile" ){
			header("location:$action.php?id=$id&id_hostgroup=$id_hostgroup");
		}
		if ( $action == "deploy_keyring" ){
			header("location:$action.php?id_keyring=$id_keyring&id_hostgroup=$id_hostgroup");
		}
		if ( $action == "deploy_key" ){
			header("location:$action.php?id_key=$id_key&id_hostgroup=$id_hostgroup");
		}
		if ( $action == "host_getinfo" ){
			header("location:$action.php?id=$id&id_hostgroup=$id_hostgroup");
		}
	}

	//echo("passwd is $passwd, id is $id, id_account is $id_account, action is $action<br>\n");
	//echo ("No action detected<br>\n$ouput<br>\n");
}
