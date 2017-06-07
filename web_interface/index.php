<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
<link rel="stylesheet" type="text/css" href="css/styles.css" />
<script src="js/jquery-1.4.4.min.js"></script>
<script type="text/javascript" src="js/jquery.titlecase.js"></script>
<script type="text/javascript" src="js/jquery.blockUI.js"></script>
<script src="scripts.js"></script>
<title>Akami Studio Touchdown Stats</title>
<link rel="Shortcut Icon" type="image/x-icon" href="images/web_logo.png" />
<body onload="make_oddeven(0)"><center>
<br>
<div id="logo"><a href="http://akami.twf.tw/"><img src="images/akami.png"></a></div>
<br>
<!-- You can add some link here
<div id="menu">
<ul>
<li><a href="http://www.google.com">Google</a></li>
<li><a href="https://www.sourcemod.net/">Sourcemod</a></li>
<li><a href="https://forums.alliedmods.net/">Alliedmodders</a></li>
</ul>
</div>
<br>
-->
<form action="index.php" method="Get" accept-charset="utf-8">
<input type="Text" name="name" value="Enter Player Name...">
<input type="Submit">
</form>
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

$start=$_GET["start"];
$s=$_GET["s"];
if (empty($start)) $start=0; 
if (empty($s)) $s=0;

$result=mysql_query("select * from ".$mysql_table."") or die('MySQL query error'); 
$nummax=mysql_numrows($result);
	
$result=mysql_query("select * from ".$mysql_table." order by points DESC limit ".$start.",".$limit."") or die('MySQL query error'); 
$numb=mysql_numrows($result); 

$rank=$start;

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
		
		// no search, display all
		if (!isset($_GET["name"]) || $_GET["name"] == "")
		{
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
		else
		{
			if(strpos(strtolower($name), strtolower($_GET["name"])) !== false)
			{
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
	}
}

echo "</table>";
echo "<table>";

if ($s>10)
{ 
	if ($s==11){ 
		$st = $s-11; 
	}
	else
	{ 
		$st = $s-10; 
	} 
	$pstart = $st*$limit; 
	
	if (!isset($_GET["name"]) || $_GET["name"] == "")
	{
		echo "<td align='center'> <a href=index.php?"; 
		echo "start=$pstart&s=$st>prev</a> "; 
	}
	else
	{
		$name=$_GET["name"];
		echo "<td align='center'> <a href=index.php?"; 
		echo "start=$pstart&s=$st&name=$name>prev</a> "; 
	}
} 

$star = $start; 
if ($s<=10)
{ 
	echo "<td align='center'>";
}
for ($page=$s;$page<($nummax/$limit);$page++) 
{ 
	$start=$page*$limit; 
	 
	if($page!=$star/$limit) 
	{ 
		if (!isset($_GET["name"]) || $_GET["name"] == "")
		{
			echo " <a href=index.php?"; 
			echo "start=$start&s=$s>"; 
		}
		else
		{
			$name=$_GET["name"];
			echo " <a href=index.php?"; 
			echo "start=$start&s=$s&name=$name>"; 
		}
	} 
	echo $page+1; 
	if($page!=$star/$limit) 
	{ 
		echo "</a> "; 
	}	 
	

	if ($page>0 && ($page%10)==0) 
	{ 
		if ($s==0) 
		{ 
			$s = $s+11; 
		}else
		{ 
			$s = $s+10; 
		} 
		$start = $start+$limit; 

		if ((($nummax/$limit)-1)>$page) 
		{ 
			if (!isset($_GET["name"]) || $_GET["name"] == "")
			{
				echo " <a href=index.php?"; 
				echo "start=$start&s=$s>next</a>"; 
			}
			else
			{
				$name=$_GET["name"];
				echo " <a href=index.php?"; 
				echo "start=$start&s=$s&name=$name>next</a>"; 
			}
		} 
		break; 
	} 
} 
echo "</td>"; 
?>
</table>
<br>
<br>
</body>
