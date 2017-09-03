<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
<link rel="stylesheet" type="text/css" href="css/styles.css" />
<script src="js/jquery-1.4.4.min.js"></script>
<script type="text/javascript" src="js/jquery.titlecase.js"></script>
<script type="text/javascript" src="js/jquery.blockUI.js"></script>
<script src="js/scripts.js"></script>
<title>Akami Studio Touchdown Stats</title>
<link rel="Shortcut Icon" type="image/x-icon" href="images/web_logo.png" />
<body onload="make_oddeven(0)"><center>
<br>
<div id="logo"><a href="http://akami.twf.tw/"><img src="images/akami.png"></a></div>
<br>
<br>
<table id='table'>
<tr>
<th>Rank</th>
<th>Name</th>
<th>Points</th>
<th>Touchdown</th>
<th>Kills</th>
<th>Deaths</th>
<th>Assists</th>
<th>Get Ball</th>
<th>Drop Ball</th>
<th>Kill Ballholder</th>
<th>Profile</th>
</tr>
<?php
require ("config.php");

$result=mysql_query("select * from ".$mysql_table."") or die('MySQL query error'); 
$numb=mysql_numrows($result);

$rank=0;

if (!empty($numb)) 
{ 
	for($i=0;$i<$numb;$i++) 
	{
		$rank++;
		$steamid=mysql_result($result,$i,"steamid"); 
		$name=mysql_result($result,$i,"name"); 
		$points=mysql_result($result,$i,"points"); 
		$kills=mysql_result($result,$i,"kills"); 
		$deaths=mysql_result($result,$i,"deaths"); 
		$assists=mysql_result($result,$i,"assists"); 
		$touchdown=mysql_result($result,$i,"touchdown"); 
		$getball=mysql_result($result,$i,"getball"); 
		$dropball=mysql_result($result,$i,"dropball"); 
		$killball=mysql_result($result,$i,"killball"); 
		
		echo "<tr><td align='center'>".$rank."</td>
			<td>".$name."</td>
			<td>".$points."</td>
			<td>".$touchdown."</td>
			<td>".$kills."</td>
			<td>".$deaths."</td>
			<td>".$assists."</td>
			<td>".$getball."</td>
			<td>".$dropball."</td>
			<td>".$killball."</td>
			<td><a href='https://steamcommunity.com/profiles/".$steamid."'>Link</a></td></tr>";
	}
}
?>
</table>
<br>
<br>
</body>
