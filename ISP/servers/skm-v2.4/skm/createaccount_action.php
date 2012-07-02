<?php

//*******************************************************

// Created by iT-CUBE SYSTEMS (TFISCHER)

//*******************************************************

include('MyFunctions.inc.php');

$action = $_GET["action"];
$name = $_GET['name'];
if (empty($name))
{
	$name = $_POST['name'];
}

$step = $_POST['step'];


if(!empty($name))
{

	if ( empty( $step ) )
	{


	?>

	<html>
	<head>
	  <title>Creating SSH user</title>
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
	  <form action="createaccount_action.php" method="Post">

	  <table class="login" align='left' height='200px' width='600px'>
	    <tr>
	      <td class='line' colspan='2'>
	        <img src='images/encrypted.gif'><br><br>
	        Provide the <b>hostname</b> where the new user "<? echo "$name"; ?>" should be created<br>
		HOST: <input type="text" name='sshhost' size='35'><br><br>
	        Provide a <b>passphrase</b> for the new SSH user<br>
       		PASS: <input type="password" name="psPassword" size='35'><br>
	      </td>
	    </tr><tr>
	      <td colspan='2'><br><input type="submit" value="Continue"><br></td>
	    </tr>
	  </table>


	  <input type="hidden" name="step" value="1">
	  <input type="hidden" name="action" value="<?php echo("$action"); ?>">
	  <input type="hidden" name="name" value="<?php echo("$name"); ?>"> 

	  </form>

	<?php end_right_pane(); ?> 
	<?php end_main_frame(); ?> 


	</body>
	</html>

	<?php
	} else {
	?>
	<html>
        <head>
          <title>Creating SSH user</title>
          <LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
        </head>
        <body>

        <?php start_main_frame(); ?>
        <?php start_left_pane(); ?>
        <?php display_menu(); ?>
        <?php end_left_pane(); ?>
        <?php start_right_pane(); ?>

	<?
		$passwd = $_POST['psPassword'];
		$action = $_POST['action'];
		$name = $_POST['name'];
		$dsthost = $_POST['sshhost'];
	       	$newusr = $name;
	
		// We create the user
		$GLOBALS['sudousr'] = $GLOBALS['sudousr'];
		$sudoident = $GLOBALS['sudoident'];

		if (!empty($passwd))
		{
			function random_float ($min,$max) {
 				  return ($min+lcg_value()*(abs($max-$min)));
			}
    			$SALT= random_float(10,20);

			$CRYPTpw = shell_exec("perl -e \"print crypt(\"$passwd\",\"$SALT\")\"");

			if (!empty($CRYPTpw))
	                {
				$output = CR_SSHUSER($sudoident,$GLOBALS['sudousr'],$dsthost,$name,$CRYPTpw);
			} else {
				print "ssh connect fail. Internal PW encryption failed. Try to use no special characters.";
				#header("location:sshconnectfail.php?result=pwENCfail");
			}

       			if ( $output == "OK" ) {
       		       	 	$output .= "Creating account successfull";
				$sshtest = TEST_SSHUSER($dsthost,$newusr,$passwd);
				
    				if ( "$sshtest" != "OK" ) {
					$output .= $sshtest;
					print "$output";
					header("location:sshconnectfail.php?result=testfail");
    				} else {
					$output .= "Testing account successful";	
					end_right_pane();
					end_main_frame();	
					header("location:createaccount.php");
				}
       			} else {
				print "Errors are: $output . \n";
				print "ssh connect fail. User creation failed.";
				#header("location:sshconnectfail.php?result=usrCRfail");
       			}
		} else {
			header("location:sshconnectfail.php?result=pwempty");
		}
	 
	//We delete the private key file
	unlink("$sudoident") or die("ATTENTION : Private key file $sudoident could not be deleted");
	end_right_pane();
	end_main_frame();
	?>	
	</body>
        </html>
	<?

	}

} else {
	//We delete the private key file
	unlink("$sudoident") or die("ATTENTION : Private key file $sudoident could not be deleted");
        die("This page cannot be called without argument... Variable: -$name- missing");
}
?>
