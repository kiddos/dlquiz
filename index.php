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
	<style type="text/css">
		#footer {
			margin-top: 35px;
			padding: 20px;
			background-color: #D8D8D8;
		}
	</style>
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

	$section1_qnum = 3;
	$indexes = generate_random_index(count($questions));
	$section1_ans = "";
	for ($i = 0 ; $i < $section1_qnum; $i ++) {
		$questions[$indexes[$i]]->setAssign($i+1);
		$questions[$indexes[$i]]->outputRightOrWrong();
		$section1_ans = $section1_ans.$questions[$indexes[$i]]->getanswer();
		if ($i != $section1_qnum-1) {
			$section1_ans = $section1_ans.",";
		}
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
	$section2_qnum = 3;
	$indexes = generate_random_index(count($questions2));
	$section2_ans = "";
	for ($i = 0 ; $i < $section2_qnum; $i ++) {
		$questions2[$indexes[$i]]->setAssign($i+1);
		$questions2[$indexes[$i]]->outputMultipleChoice();
		$section2_ans = $section2_ans.$questions2[$indexes[$i]]->getanswer();
		if ($i != $section2_qnum-1) {
			$section2_ans = $section2_ans.",";
		}
	}
	?>

	<form class="form-inline" action="" accept-charset="utf-8" role="form">
		<div class="form-group">
			<label for="submit" style="margin-right: 10px">Submit Your Answer: </label>
			<input type="button" value="submit" id="submit" onclick="submitAns()">
		</div>
	</form>

	<div class="alert alert-danger fade in" id="notdone" style="display: none"></div>

	<p id="score" class="text-success" style="display: none"></p>

	<script type="text/javascript" charset="utf-8">
		function checkQuestionDone(section, n) {
			if (section == 1) {
				var radios = document.getElementsByName("choice"+n);
				for (var i = 0 ; i < radios.length ; i ++) {
					if (radios[i].checked) {
						return true;
					}
				}
			} else if (section == 2) {
				var radios = document.getElementsByName("mchoice"+n);
				for (var i = 0 ; i < radios.length ; i ++) {
					if (radios[i].checked) {
						return true;
					}
				}
			}
			return false;
		}
		function checkSectionDone(section) {
			for (var i = 0 ; i < <?php echo $section1_qnum; ?> ; i ++) {
				if (!checkQuestionDone(section, i+1)) {
					return i+1;
				}
			}
			return 0;
		}
		function submitAns() {
			// set warning tag to invisible at first
			var warningTag = document.getElementById("notdone");
			document.getElementById("score").style.display = "none";
			warningTag.style.display = "none";

			var status1 = checkSectionDone(1);
			var status2 = checkSectionDone(2);
			if (status1 != 0) {
				warningTag = document.getElementById("notdone");
				warningTag.style.display = "";
				warningTag.innerHTML = "<strong>Submit Failed!</strong>  <i>[Section 1]</i> Question " +
						status1 + " is not answered";
			} else if (status2 != 0) {
				warningTag = document.getElementById("notdone");
				warningTag.style.display = "";
				warningTag.innerHTML = "<strong>Submit Failed!</strong>  <i>[Section 2]</i> Question " +
						status2 + " is not answered";
			} else {
				// successfully filled out all answers
				// process section 1
				var section1_ans = "<?php echo $section1_ans; ?>";
				var section1_ans_list = section1_ans.split(",");
				var correct_count1 = 0;
				for (var i = 0 ; i < <?php echo $section1_qnum; ?> ; i ++) {
					var radios = document.getElementsByName("choice"+(i+1));
					for (var j = 0 ; j < radios.length ; j ++) {
						if (radios[j].checked) {
							var correct_answer = section1_ans_list[i];
							var content = document.getElementById("answer1-"+(i+1)).innerHTML;
							if (radios[j].value != correct_answer) {
								document.getElementById("answer1-"+(i+1)).className = "text-danger";
								content = "<br>wrong! answer: " + correct_answer + "<br>";
								document.getElementById("answer1-"+(i+1)).innerHTML = content;
							} else {
								document.getElementById("answer1-"+(i+1)).className = "text-success";
								content = "<br>correct! answer: " + correct_answer + "<br>";
								document.getElementById("answer1-"+(i+1)).innerHTML = content;
								correct_count1 ++;
							}
						}
					}
				}

				// process section 2
				var section2_ans = "<?php echo $section2_ans; ?>";
				var section2_ans_list = section2_ans.split(",");
				var correct_count2 = 0;
				for (var i = 0 ; i < <?php echo $section2_qnum; ?> ; i ++) {
					var radios = document.getElementsByName("mchoice"+(i+1));
					for (var j = 0 ; j < radios.length ; j ++) {
						if (radios[j].checked) {
							var correct_answer = section2_ans_list[i];
							var content = document.getElementById("answer2-"+(i+1)).innerHTML;
							if (radios[j].value != correct_answer) {
								document.getElementById("answer2-"+(i+1)).className = "text-danger";
								content = "<br>wrong! answer: " + correct_answer + "<br>";
								document.getElementById("answer2-"+(i+1)).innerHTML = content;
							} else {
								document.getElementById("answer2-"+(i+1)).className = "text-success";
								content = "<br>correct! answer: " + correct_answer + "<br>";
								document.getElementById("answer2-"+(i+1)).innerHTML = content;
								correct_count1 ++;
							}
						}
					}
				}

				// sum result
				var total_ques = <?php echo $section1_qnum + $section2_qnum;?>;
				var total_correct = correct_count1 + correct_count2;
				var score = "score: " + total_correct + "/" + total_ques;
				document.getElementById("score").innerHTML = score;
				document.getElementById("score").style.display = "";
				if (total_correct * 1.0 / total_ques < 0.80) {
					document.getElementById("score").className = "text-danger";
					document.getElementById("score").innerHTML += " (Failed)";
				} else {
					document.getElementById("score").className = "text-success";
					document.getElementById("score").innerHTML += " (Passed)";
				}
			}
		}
	</script>

	<footer class="footer" id="footer">
		<div>
			Made by Joseph Yu (2015/8/9)
		</div>
	</footer>
</div>

</body>
</html>
