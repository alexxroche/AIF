<?php include('MyFunctions.inc.php');

$name = "";
$ip = "";
$id_hostgroup = "";
// Setting all variables 
$serialno = "";
$memory = "";
$osversion = "";
$cabinet = "";
$uloc = "";
$cageno = "";
$model = "";
$procno = "";
$provider = "";
$install_dt = "";
$po = "";
$cost = "";
$maint_cost = "";
$maint_po = "";
$maint_provider = "";
$maint_end_dt = "";
$life_end_dt = "";
$ostype = "";
$osvers = "";
$intf1 = "";
$intf2 = "";
$defaultgw = "";
$monitor = "";
$selinux = "";
$datechgroot = "";

	if (isset($_POST["step"])) $step = $_POST["step"]; else $step = "";

if(isset($_POST["ns_lookup"]))
{
	$name=$_POST["name"];
	
	if(preg_match("/^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$/", gethostbyname($_POST["name"])) == 0)
	{
		$ip="Non-existent domain";
	}
	else $ip=gethostbyname($_POST["name"]);
	
	$id = $_GET['id'];
	if (!empty($id))
	{
		// We modify an existing reminder
		$result = mysql_query( "SELECT * FROM `hosts` where `id`='$id'" )
				or die (mysql_error()."<br>Couldn't execute query: $query");
		$row = mysql_fetch_array( $result );
		$name = $row["name"];
		$ip = $row["ip"];
		$id_hostgroup = $row["id_group"];
		// Setting all variables 
		$serialno = $row["serialno"];
		$memory = $row["memory"];
		$osversion = $row["osversion"];
		$cabinet = $row["cabinet"];
		$uloc = $row["uloc"];
		$cageno = $row["cageno"];
		$model = $row["model"];
		$procno = $row["procno"];
		$provider = $row["provider"];
		$install_dt = $row["install_dt"];
		$po = $row["po"];
		$cost = $row["cost"];
		$maint_cost = $row["maint_cost"];
		$maint_po = $row["maint_po"];
		$maint_provider = $row["maint_provider"];
		$maint_end_dt = $row["maint_end_dt"];
		$life_end_dt = $row["life_end_dt"];
		$ostype = $row["ostype"];
		$osvers = $row["osvers"];
		$intf1 = $row["intf1"];
		$intf2 = $row["intf2"];
		$defaultgw = $row["defaultgw"];
		$monitor = $row["monitor"];
		$selinux = $row["selinux"];
		$datechgroot = $row["datechgroot"];
	}

	?>

	<html>
	<HEAD>
	<TITLE>Host Setup</TITLE>
	<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
	</HEAD>
	<BODY>

	<?php start_main_frame(); ?>
	<?php start_left_pane(); ?>
	<?php display_menu(); ?>
	<?php end_left_pane(); ?>
	<?php start_right_pane(); ?>

		<center>
		<form name="setup_host" action="hosts_setup.php" method="post">

		<!-- Host info -->
		<fieldset><legend>Add / Modify a host</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr>
			<td class="Type" width="40%">Host Name : </td>
			<td class="Content" width="60%">
			<input name="name" size="50" type="text" maxlength="255" value="<?php echo("$name"); ?>">
			</td>
		  </tr>
		  <tr>
			<td class="Type" width="40%">Host IP :</td>
			<td class="Content" width="60%">
			<input name="ip" size="50" type="text" maxlength="255" value="<?php echo("$ip"); ?>">
			<input name="ns_lookup" type="submit" value="get IP">
			</td>
		  </tr>
		  <tr>
			<td class="Type">Host group available : </td>
			<td class="Content" width="60%">
			<?php display_available_groups("$id_hostgroup"); ?>
			</td>
		  </tr>
		</table>
		</fieldset>


		<!-- Installation info -->
		<fieldset><legend>Installation information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%"> OS Type : </td> <td class="Content" width="60%">
		  <input name="ostype" size="50" type="text" maxlength="255" value="<?php echo("$ostype"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> OS Version : </td> <td class="Content" width="60%">
		  <input name="osvers" size="50" type="text" maxlength="255" value="<?php echo("$osvers"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Interface #1 : </td> <td class="Content" width="60%">
		  <input name="intf1" size="50" type="text" maxlength="255" value="<?php echo("$intf1"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Interface #2 : </td> <td class="Content" width="60%">
		  <input name="intf2" size="50" type="text" maxlength="255" value="<?php echo("$intf2"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Default Gateway : </td> <td class="Content" width="60%">
		  <input name="defaultgw" size="50" type="text" maxlength="255" value="<?php echo("$defaultgw"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Is this hosts monitored ? : </td> <td class="Content" width="60%">
		  <input name="monitor" size="50" type="text" maxlength="255" value="<?php echo("$monitor"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> SELINUX config : </td> <td class="Content" width="60%">
		  <input name="selinux" size="50" type="text" maxlength="255" value="<?php echo("$selinux"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Root passwd change date : </td> <td class="Content" width="60%">
		  <input name="datechgroot" size="50" type="text" maxlength="255" value="<?php echo("$datechgroot"); ?>"> </td> </tr>
		</table>
		</fieldset>

		<!-- Additional info -->
		<fieldset><legend>Additional information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%">Serial Number : </td> <td class="Content" width="60%">
		  <input name="serialno" size="50" type="text" maxlength="255" value="<?php echo("$serialno"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Model : </td> <td class="Content" width="60%">
		  <input name="model" size="50" type="text" maxlength="255" value="<?php echo("$model"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Memory : </td> <td class="Content" width="60%">
		  <input name="memory" size="50" type="text" maxlength="255" value="<?php echo("$memory"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Processor Info : </td> <td class="Content" width="60%">
		  <input name="procno" size="50" type="text" maxlength="255" value="<?php echo("$procno"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Provider : </td> <td class="Content" width="60%">
		  <input name="provider" size="50" type="text" maxlength="255" value="<?php echo("$provider"); ?>"> </td> </tr>
		</table>
		</fieldset>

		<!-- Location Information -->
		<fieldset><legend>Location information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%">Cage Number : </td> <td class="Content" width="60%">
		  <input name="cageno" size="50" type="text" maxlength="255" value="<?php echo("$cageno"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Cabinet : </td> <td class="Content" width="60%">
		  <input name="cabinet" size="50" type="text" maxlength="255" value="<?php echo("$cabinet"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">U Location: </td> <td class="Content" width="60%">
		  <input name="uloc" size="50" type="text" maxlength="255" value="<?php echo("$uloc"); ?>"> </td> </tr>
		</table>
		</fieldset>
		<fieldset><legend>Contract information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%">Installation date : </td> <td class="Content" width="60%">
		  <input name="install_dt" size="10" type="text" maxlength="255" value="<?php echo("$install_dt"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">PO : </td> <td class="Content" width="60%">
		  <input name="po" size="11" type="text" maxlength="255" value="<?php echo("$po"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Initial cost: </td> <td class="Content" width="60%">
		  <input name="cost" size="12" type="text" maxlength="255" value="<?php echo("$cost"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance cost: </td> <td class="Content" width="60%">
		  <input name="maint_cost" size="12" type="text" maxlength="255" value="<?php echo("$maint_cost"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance PO : </td> <td class="Content" width="60%">
		  <input name="maint_po" size="11" type="text" maxlength="255" value="<?php echo("$maint_po"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance Provider : </td> <td class="Content" width="60%">
		  <input name="maint_provider" size="50" type="text" maxlength="255" value="<?php echo("$maint_provider"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance end : </td> <td class="Content" width="60%">
		  <input name="maint_end_dt" size="10" type="text" maxlength="255" value="<?php echo("$maint_end_dt"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">End of life : </td> <td class="Content" width="60%">
		  <input name="life_end_dt" size="10" type="text" maxlength="255" value="<?php echo("$life_end_dt"); ?>"> </td> </tr>
		</table>
		</fieldset>
		<center>
		  <input name="step" type="hidden" value="1">
		  <input name="id" type="hidden" value="<?php echo("$id");?>">
		  <input name="submit" type="submit" value="add/modify">
		</center>
		</form>
		</center>

	<? end_right_pane(); ?>
	<? end_main_frame(); ?>


	</body>
	</html>

	<?php
}
elseif($step != '1' && !isset($_POST["ns_lookup"]))
{
	if (isset($_GET["id"])) $id = $_GET["id"]; else $id = "";
	if (!empty($id))
	{
		// We modify an existing reminder
		$result = mysql_query( "SELECT * FROM `hosts` where `id`='$id'" )
				or die (mysql_error()."<br>Couldn't execute query: $query");
		$row = mysql_fetch_array( $result );
		$name = $row["name"];
		$ip = $row["ip"];
		$id_hostgroup = $row["id_group"];
		// Setting all variables 
		$serialno = $row["serialno"];
		$memory = $row["memory"];
		$osversion = $row["osversion"];
		$cabinet = $row["cabinet"];
		$uloc = $row["uloc"];
		$cageno = $row["cageno"];
		$model = $row["model"];
		$procno = $row["procno"];
		$provider = $row["provider"];
		$install_dt = $row["install_dt"];
		$po = $row["po"];
		$cost = $row["cost"];
		$maint_cost = $row["maint_cost"];
		$maint_po = $row["maint_po"];
		$maint_provider = $row["maint_provider"];
		$maint_end_dt = $row["maint_end_dt"];
		$life_end_dt = $row["life_end_dt"];
		$ostype = $row["ostype"];
		$osvers = $row["osvers"];
		$intf1 = $row["intf1"];
		$intf2 = $row["intf2"];
		$defaultgw = $row["defaultgw"];
		$monitor = $row["monitor"];
		$selinux = $row["selinux"];
		$datechgroot = $row["datechgroot"];
	}

	?>

	<html>
	<HEAD>
	<TITLE>Host Setup</TITLE>
	<LINK REL=STYLESHEET HREF="skm.css" TYPE="text/css">
	</HEAD>
	<BODY>

	<?php start_main_frame(); ?>
	<?php start_left_pane(); ?>
	<?php display_menu(); ?>
	<?php end_left_pane(); ?>
	<?php start_right_pane(); ?>

		<center>
		<form name="setup_host" action="hosts_setup.php" method="post">

		<!-- Host info -->
		<fieldset><legend>Add / Modify a host</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr>
			<td class="Type" width="40%">Host Name : </td>
			<td class="Content" width="60%">
			<input name="name" size="50" type="text" maxlength="255" value="<?php echo("$name"); ?>">
			</td>
		  </tr>
		  <tr>
			<td class="Type" width="40%">Host IP :</td>
			<td class="Content" width="60%">
			<input name="ip" size="50" type="text" maxlength="255" value="<?php echo("$ip"); ?>">
			<input name="ns_lookup" type="submit" value="get IP">
			</td>
		  </tr>
		  <tr>
			<td class="Type">Host group available : </td>
			<td class="Content" width="60%">
			<?php display_available_groups("$id_hostgroup"); ?>
			</td>
		  </tr>
		</table>
		</fieldset>


		<!-- Installation info -->
		<fieldset><legend>Installation information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%"> OS Type : </td> <td class="Content" width="60%">
		  <input name="ostype" size="50" type="text" maxlength="255" value="<?php echo("$ostype"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> OS Version : </td> <td class="Content" width="60%">
		  <input name="osvers" size="50" type="text" maxlength="255" value="<?php echo("$osvers"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Interface #1 : </td> <td class="Content" width="60%">
		  <input name="intf1" size="50" type="text" maxlength="255" value="<?php echo("$intf1"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Interface #2 : </td> <td class="Content" width="60%">
		  <input name="intf2" size="50" type="text" maxlength="255" value="<?php echo("$intf2"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Default Gateway : </td> <td class="Content" width="60%">
		  <input name="defaultgw" size="50" type="text" maxlength="255" value="<?php echo("$defaultgw"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Is this hosts monitored ? : </td> <td class="Content" width="60%">
		  <input name="monitor" size="50" type="text" maxlength="255" value="<?php echo("$monitor"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> SELINUX config : </td> <td class="Content" width="60%">
		  <input name="selinux" size="50" type="text" maxlength="255" value="<?php echo("$selinux"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%"> Root passwd change date : </td> <td class="Content" width="60%">
		  <input name="datechgroot" size="50" type="text" maxlength="255" value="<?php echo("$datechgroot"); ?>"> </td> </tr>
		</table>
		</fieldset>

		<!-- Additional info -->
		<fieldset><legend>Additional information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%">Serial Number : </td> <td class="Content" width="60%">
		  <input name="serialno" size="50" type="text" maxlength="255" value="<?php echo("$serialno"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Model : </td> <td class="Content" width="60%">
		  <input name="model" size="50" type="text" maxlength="255" value="<?php echo("$model"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Memory : </td> <td class="Content" width="60%">
		  <input name="memory" size="50" type="text" maxlength="255" value="<?php echo("$memory"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Processor Info : </td> <td class="Content" width="60%">
		  <input name="procno" size="50" type="text" maxlength="255" value="<?php echo("$procno"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Provider : </td> <td class="Content" width="60%">
		  <input name="provider" size="50" type="text" maxlength="255" value="<?php echo("$provider"); ?>"> </td> </tr>
		</table>
		</fieldset>

		<!-- Location Information -->
		<fieldset><legend>Location information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%">Cage Number : </td> <td class="Content" width="60%">
		  <input name="cageno" size="50" type="text" maxlength="255" value="<?php echo("$cageno"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Cabinet : </td> <td class="Content" width="60%">
		  <input name="cabinet" size="50" type="text" maxlength="255" value="<?php echo("$cabinet"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">U Location: </td> <td class="Content" width="60%">
		  <input name="uloc" size="50" type="text" maxlength="255" value="<?php echo("$uloc"); ?>"> </td> </tr>
		</table>
		</fieldset>
		<fieldset><legend>Contract information</legend>
		<table border='0' align='center' class="modif_contact">
		  <tr> <td class="Type" width="40%">Installation date : </td> <td class="Content" width="60%">
		  <input name="install_dt" size="10" type="text" maxlength="255" value="<?php echo("$install_dt"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">PO : </td> <td class="Content" width="60%">
		  <input name="po" size="11" type="text" maxlength="255" value="<?php echo("$po"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Initial cost: </td> <td class="Content" width="60%">
		  <input name="cost" size="12" type="text" maxlength="255" value="<?php echo("$cost"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance cost: </td> <td class="Content" width="60%">
		  <input name="maint_cost" size="12" type="text" maxlength="255" value="<?php echo("$maint_cost"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance PO : </td> <td class="Content" width="60%">
		  <input name="maint_po" size="11" type="text" maxlength="255" value="<?php echo("$maint_po"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance Provider : </td> <td class="Content" width="60%">
		  <input name="maint_provider" size="50" type="text" maxlength="255" value="<?php echo("$maint_provider"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">Maintenance end : </td> <td class="Content" width="60%">
		  <input name="maint_end_dt" size="10" type="text" maxlength="255" value="<?php echo("$maint_end_dt"); ?>"> </td> </tr>
		  <tr> <td class="Type" width="40%">End of life : </td> <td class="Content" width="60%">
		  <input name="life_end_dt" size="10" type="text" maxlength="255" value="<?php echo("$life_end_dt"); ?>"> </td> </tr>
		</table>
		</fieldset>
		<center>
		  <input name="step" type="hidden" value="1">
		  <input name="id" type="hidden" value="<?php echo("$id");?>">
		  <input name="submit" type="submit" value="add/modify">
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
{
    $id = $_POST['id'];
    // this is a new host
    $name = $_POST['name'];
	$ip = $_POST['ip'];
    $group = $_POST['group'];
    $serialno = $_POST["serialno"];
    $memory = $_POST["memory"];
    $osversion = $_POST["osversion"];
    $cabinet = $_POST["cabinet"];
    $uloc = $_POST["uloc"];
    $cageno = $_POST["cageno"];
    $model = $_POST["model"];
    $procno = $_POST["procno"];
    $provider = $_POST["provider"];
    $install_dt = $_POST["install_dt"];
    $po = $_POST["po"];
    $cost = $_POST["cost"];
    $maint_cost = $_POST["maint_cost"];
    $maint_po = $_POST["maint_po"];
    $maint_provider = $_POST["maint_provider"];
    $maint_end_dt = $_POST["maint_end_dt"];
    $life_end_dt = $_POST["life_end_dt"];
    $ostype = $_POST["ostype"];
    $osvers = $_POST["osvers"];
    $intf1 = $_POST["intf1"];
    $intf2 = $_POST["intf2"];
    $defaultgw = $_POST["defaultgw"];
    $monitor = $_POST["monitor"];
    $selinux = $_POST["selinux"];
    $datechgroot = $_POST["datechgroot"];

    if(empty($id)){
    // this is a new host
      // No error let's add the entry
      $query = mysql_query( "INSERT INTO `hosts` (`name`,`ip`,`id_group`,`serialno`,`memory`,`osversion`,`cabinet`,`uloc`,`cageno`,`model`,`procno`,`provider`,`install_dt`,`po`,`cost`,`maint_cost`,`maint_po`,`maint_provider`,`maint_end_dt`,`life_end_dt`,`ostype`,`osvers`,`intf1`,`intf2`,`defaultgw`,`monitor`,`selinux`,`datechgroot`) VALUES('$name','$ip','$group','$serialno','$memory','$osversion','$cabinet','$uloc','$cageno','$model','$procno','$provider','$install_dt','$po','$cost','$maint_cost','$maint_po','$maint_provider','$maint_end_dt','$life_end_dt','$ostype','$osvers','$intf1','$intf2','$defaultgw','$monitor','$selinux','$datechgroot')" ) or die(mysql_error()."<br>Couldn't execute query: $query");
	  $id = mysql_insert_id();
      // add account root (id 1) to created host
      mysql_query("INSERT INTO `hosts-accounts` (`id_host`,`id_account`) VALUES ('$id','1')");
      // add SKM Public Key (id 1) for user root on created host
      mysql_query("INSERT INTO `hak` (`id_host`,`id_account`,`id_key`) VALUES ('$id','1','1')");
      header("Location:hosts-view.php?id_hostgroup=$group");
      echo ("host Added, redirecting...");
      exit ();
    } else {
      // We modify an existing reminder
      // setting the variable for the update
      $name = $_POST['name'];
      mysql_query( "UPDATE `hosts` SET `name` = '$name',`ip`='$ip',`id_group`='$group',`serialno`='$serialno',`memory`='$memory',`osversion`='$osversion',`cabinet`='$cabinet',`uloc`='$uloc',`cageno`='$cageno',`model`='$model',`procno`='$procno',`provider`='$provider',`install_dt`='$install_dt',`po`='$po',`cost`='$cost',`maint_cost`='$maint_cost',`maint_po`='$maint_po',`maint_provider`='$maint_provider',`maint_end_dt`='$maint_end_dt',`life_end_dt`='$life_end_dt',`ostype`='$ostype',`osvers`='$osvers',`intf1`='$intf1',`intf2`='$intf2',`defaultgw`='$defaultgw',`monitor`='$monitor',`selinux`='$selinux',`datechgroot`='$datechgroot' WHERE `id` = '$id' " ) or die(mysql_error()."<br>Couldn't execute query: $query");
      // Let's go to the Reminder List page
      header("Location:host-view.php?id_hostgroup=$group&id=$id");
      echo ("host Modified, redirecting...");
      exit ();
    }

}
?>

