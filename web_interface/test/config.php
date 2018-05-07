<?php
$mysql_user = "kentotw_webuser"; // DATABASE USER
$mysql_pass = "njkhaxdqp7o2";// DATABASE PASS
$mysql_db = "kentotw_csgo_server";// DATABASE
$mysql_host = "localhost";	// DATABASE HOST
$mysql_table = "touchdown"; // DATABASE TABLE BEING USED AT THE PLUGIN. ("sm_touchdown_stats_table" cvar). Default: touchdown.
$logo = ""; // WEB LOGO DISPLAY ON PAGE TOP
$title = ""; // WEB TITLE
$icon = ""; // WEB ICON
$home = ""; // LINK WHEN CLICK LOGO

$link = mysqli_connect($mysql_host, $mysql_user, $mysql_pass, $mysql_db);
mysqli_set_charset ($link , "utf-8");
?>
