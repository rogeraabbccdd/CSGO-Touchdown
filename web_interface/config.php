<?php
$mysql_user = ""; // DATABASE USER
$mysql_password = "";// DATABASE PASS
$mysql_database = "";// DATABASE
$mysql_host = "";	// DATABASE HOST
$mysql_table = ""; // DATABASE TABLE BEING USED AT THE PLUGIN. ("sm_touchdown_stats_table" cvar). Default: touchdown.
$logo = ""; // WEB LOGO
$title = ""; // WEB TITLE
$home = ""; // HOMEPAGE LINK
$icon = ""; // WEB ICON

$link = mysqli_connect($mysql_host, $mysql_user, $mysql_password, $mysql_database);
mysqli_set_charset ($link , "utf-8");
?>
