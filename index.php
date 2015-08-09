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

	function generate_random_index($num) {
		$indexes = array();
		for ($i = 0 ; $i < $num; $i ++) {
			$indexes[$i] = $i;
		}
		for ($i = 0 ; $i < $num * 3; $i ++) {
			$index1 = rand(0, $num-1);
			$index2 = rand(0, $num-1);
			if ($index1 != $index2) {
				$temp = $indexes[$index1];
				$indexes[$index1] = $indexes[$index2];
				$indexes[$index2] = $temp;
			}
		}
		return $indexes;
	}


	$file = fopen("./questions/yesno/1.txt", "r");
	$content = "";
	$splitstr = "splitting";
	while (!feof($file)) {
		$data = trim(stream_get_line($file, 1024, "\n"));
		if ($data == "" || $data == "\n") {
			continue;
		}
		$last2 = substr($data, strlen($data)-2);
		if (is_numeric($last2[0]) && is_numeric($last2[1])) {
			$content = $content.$data.$splitstr;
		} else {
			$content = $content.' '.$data;
		}
	}
	$lines = split($splitstr, $content);
	$questions = array();
	$counter = 0;
	foreach ($lines as $line) {
		if ($line != null && $line != "" && $line != " ") {
			$line = str_replace("\t", "", $line);
			$line = str_replace("  ", " ", $line);
			if ($line[0] == " ") {
				$line = substr($line, 1);
			}

			$line_data = split(" ", $line);
			$num = $line_data[0];
			$ans = $line_data[1];
			$first_space = strpos($line, " ");
			$second_space = strpos($line, " ", $first_space+1);
			$question = substr($line, $second_space+1);
			$question = substr($question, 0, strlen($question)-2);
			$question = str_replace(" ", "", $question);
			$questions[$counter] = new Question($num, $ans, $question);
			//$questions[$counter]->outputRightOrWrong();
			$counter ++;
			//echo $line.'<br>';
		}
	}

	$section1_qnum = 50;
	$indexes = generate_random_index($section1_qnum);
	for ($i = 0 ; $i < $section1_qnum; $i ++) {
		$questions[$indexes[$i]]->setAssign($i+1);
		$questions[$indexes[$i]]->outputRightOrWrong();
	}
	?>

	<div class="row" style="padding-bottom: 10px;">
		<h4 class="col-xs-12">Section 2: Multiple Choice</h4>
	</div>
	<?php
	$file = fopen("./questions/multiple/1.txt", "r");
	$content = "";
	while (!feof($file)) {
		$data = trim(stream_get_line($file, 1024, "\n"));
		if ($data == "" || $data == "\n") {
			continue;
		}
		$last2 = substr($data, strlen($data)-2);
		if (is_numeric($last2[0]) && is_numeric($last2[1])) {
			$content = $content.$data.$splitstr;
		} else {
			$content = $content.' '.$data;
		}
	}

	$lines = split($splitstr, $content);
	$counter = 0;
	$questions2 = array();
	foreach ($lines as $line) {
		if ($line != null && $line != "" && $line != " ") {
			$line = str_replace("\t", "", $line);
			$line = str_replace("  ", " ", $line);
			if ($line[0] == " ") {
				$line = substr($line, 1);
			}
			$line_data = split(" ", $line);
			$num = $line_data[0];
			$ans = $line_data[1];
			$first_space = strpos($line, " ");
			$second_space = strpos($line, " ", $first_space+1);
			$question = substr($line, $second_space+1);
			$question = substr($question, 0, strlen($question)-2);
			$question = str_replace(" ", "", $question);
			$questions2[$counter] = new Question($num, $ans, $question);
			//$questions2[$counter]->outputMultipleChoice();
			$counter ++;
			//echo $line.'<br>';
		}
	}
	$section2_qnum = 50;
	$indexes = generate_random_index($section1_qnum);
	for ($i = 0 ; $i < $section2_qnum; $i ++) {
		$questions2[$indexes[$i]]->setAssign($i+1);
		$questions2[$indexes[$i]]->outputMultipleChoice();
	}
	?>

	<div class="form-group" style="margin-top: 10px">
		<form action="" accept-charset="utf-8" role="form">
			<label for="submit" style="margin-right: 10px">Submit Your Answer: </label>
			<input type="button" name="submit" value="submit" id="submit">
		</form>
	</div>

	<footer class="footer">
		<div class="well">
			Made by Joseph Yu (2015/8/9)
		</div>
	</footer>
</div>

</body>
</html>
