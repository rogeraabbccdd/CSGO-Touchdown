<?php
	require_once "config.php";
?>
<head>
	<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
	<link rel="stylesheet" type="text/css" href="css/styles.css" />
	<script src="js/jquery-3.3.1.min.js" type="text/javascript"></script>
	<script src="js/datatables.js" type="text/javascript"></script>
	<title><?=$title?></title>
	<link rel="Icon" href="<?=$icon?>" />
</head>
<body>
	<br>
	<div id="logo"><a href="<?=$home?>"><img src="<?=$logo?>"></a></div>
	<br>
	<br>
	<table id='statstable' align="center">
		<thead>
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
		</thead>
		<tbody>
			<?php
				$result=mysqli_query($link, "
				SELECT a.*
					FROM (SELECT *, @prev := @curr, @curr := points, @rank := IF(@prev = @curr, @rank, @rank+1) AS rank
						FROM ".$mysql_table.", (SELECT @curr := null, @prev := null, @rank := 0) s
					ORDER BY points DESC) a");
				mysqli_set_charset ($link , "utf-8");
						
				$numb=mysqli_num_rows($result); 

				if (!empty($numb)) 
				{ 
					while ($row = mysqli_fetch_array($result))
					{
						$rank = $row["rank"]; 
						$steamid = $row["steamid"]; 
						$name= $row["name"]; 
						$points= $row["points"]; 
						$kills= $row["kills"]; 
						$deaths= $row["deaths"]; 
						$assists= $row["assists"]; 
						$touchdown= $row["touchdown"]; 
						$getball= $row["getball"]; 
						$dropball= $row["dropball"]; 
						$killball= $row["killball"]; 
						
						echo "<tr>
							<td align='center'>".$rank."</td>
							<td>".$name."</td>
							<td>".$points."</td>
							<td>".$touchdown."</td>
							<td>".$kills."</td>
							<td>".$deaths."</td>
							<td>".$assists."</td>
							<td>".$getball."</td>
							<td>".$dropball."</td>
							<td>".$killball."</td>
							<td><a href='https://steamcommunity.com/profiles/".$steamid."'>Link</a></td>
							</tr>";
					}
				}
			?>
		<tbody>
	</table>
	<br>
	<br>
</body>
<script>
	$(document).ready(function() {
		$('#statstable').DataTable();
	});
</script>
