<!DOCTYPE HTML>

<html lang="zh-TW">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1">
	<title>Driver License Quiz</title>
	<link rel="icon" type="image/x-icon" href="res/icon.ico">
	<link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" />
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
	<script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js"></script>
</head>

<body>

<div class="container">
	<div class="jumbotron" style="padding: 10px">
		<h1>Driver License Quiz</h1>
		<p>Updated July 2015</p>
	</div>

	<div class="row" style="padding-bottom: 10px;">
		<h4 class="col-xs-12">Section 1: Right or Wrong Questions</h4>
	</div>
	<?php
	include 'question.php';

	function is_question($line) {
		$parts = split("\n", $line);
		foreach ($parts as $part) {
			$part = str_replace("\n", "", $part);
			$part = str_replace(" ", "", $part);
			if (is_numeric($part)) {
				return true;
			}
		}
		return false;
	}


	// section 1
	$file = fopen("./questions/yesno/1.txt", "r");
	$content = array();
	$counter = 0;
	while (!feof($file)) {
		$data = trim(stream_get_line($file, 1024, "。"));
		if ($data == "" || $data == "\n") {
			continue;
		}
		if ($counter != 0) {
			$data = str_replace("\n", "\t", $data);
			$start = strpos($data, "\t", 2);
			$data = substr($data, $start);
		}
		$data = trim(str_replace("  ", " ", $data));
		$data = str_replace("\t", " ", $data);
		if ($data != null && $data != "" && $data != " " && !is_numeric($data)) {
			$content[$counter] = $data;
			$counter ++;
		}
	}

	for ($i = 0 ; $i < count($content); $i ++) {
		$index1 = rand(0, count($content)-1);
		$index2 = rand(0, count($content)-1);
		if ($index1 != $index2) {
			$temp = $content[$index1];
			$content[$index1] = $content[$index2];
			$content[$index2] = $temp;
		}
	}
	$questions = array();
	$counter = 0;
	foreach ($content as $line) {
		$first_space = strpos($line, " ");
		$num = substr($line, 0, $first_space);
		$second_space = strpos($line, " ", $first_space+1);
		$ans = substr($line, $first_space+1, $second_space);
		$ques = substr($line, $second_space+1);
		$questions[$counter] = new Question($num, $and, $ques, $counter+1);
		$counter++;
		//$questions[$counter-1]->output();
		//echo $line . '<br>';
	}
	unset($content);

	// display the question
	$sec1_question_num = 50;
	for ($i = 0 ; $i < $sec1_question_num; $i ++) {
		$questions[$i]->output();
	}
	?>

	<div class="form-group" style="margin-top: 10px">
		<form action="" accept-charset="utf-8" role="form">
			<label for="submit" style="margin-right: 10px">Submit Your Answer: </label>
			<input type="button" name="submit" value="submit" id="submit">
		</form>
	</div>
</div>

</body>
</html>
