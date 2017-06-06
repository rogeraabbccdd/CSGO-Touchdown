<?php
$mysql_user = ""; // DATABASE USER
$mysql_password = "";// DATABASE PASS
$mysql_database = "";// DATABASE
$mysql_host = "";	// DATABASE HOST
$mysql_table = "touchdown"; // DATABASE TABLE BEING USED AT THE PLUGIN. ("sm_touchdown_stats_table" cvar). Default: touchdown.

$limit = "20"; //How many results per page.
$link = mysql_connect($mysql_host, $mysql_user, $mysql_password);
mysql_select_db($mysql_database,$link);
?>
