<?php
class Question {
	private static $count = 0;
	private $num;
	private $ans;
	private $question;
	private $assign;
	function __construct($num, $ans, $question) {
		$this->num = $num;
		$this->ans = $ans;
		$this->question = $question;
		$this->assign = $assign;
	}

	function setAssign($assign) {
		$this->assign = $assign;
	}

	// template
	//<div class="row">
		//<div class="col-xs-4">
			//<div class="form-group">
				//<label id="qnum"><em>1.</em></label>
				//<input type="radio" name="choice" value="O" id="qradio"><label id="oxtext">O</label>
				//<input type="radio" name="choice" value="X" id="qradio"><label id="oxtext">X</label>
			//</div>
		//</div>
		//<div class="col-xs-8">
			//<p>This is question number 1 should you choose O or X</p>
		//</div>
	//</div>
	function outputRightOrWrong() {
		echo '<div class="row">';
		echo '<div class="col-xs-4 col-sm-4 col-md-3 col-lg-2">';
		echo '<div class="form-group">';
		echo '<form class="form-group" action="" method="" accept-charset="utf-8" role="form">';
		echo "<label style=\"margin-right: 6px\"><em>$this->assign.</em></label>";
		echo "<input type=\"radio\" name=\"choice$this->assign\" value=\"O\" style=\"margin-right: 3px\"><label style=\"margin-right: 3px\">O</label>";
		echo "<input type=\"radio\" name=\"choice$this->assign\" value=\"X\"><label style=\"margin-right: 3px\">X</label>";
		echo '</form>';
		echo '</div>';
		echo '</div>';
		echo '<div class="col-xs-8 col-sm-8 col-md-9 col-lg-10">';
		echo "<p>$this->question<br>";
		echo "<sub>Question $this->num in database</sub></p>";
		echo '</div>';
		echo '</div>'."\n";
	}

	function outputMultipleChoice() {
		echo '<div class="row">';
		echo '<div class="col-xs-5 col-sm-5 col-md-4 col-lg-2">';
		echo '<div class="form-group">';
		echo '<form class="form-group" action="" method="" accept-charset="utf-8" role="form">';
		echo "<label style=\"margin-right: 6px\"><em>$this->assign.</em></label>";
		echo "<input type=\"radio\" name=\"mchoice$this->assign\" value=\"1\" style=\"margin-right: 3px\"><label style=\"margin-right: 3px\">1</label>";
		echo "<input type=\"radio\" name=\"mchoice$this->assign\" value=\"2\" style=\"margin-right: 3px\"><label style=\"margin-right: 3px\">2</label>";
		echo "<input type=\"radio\" name=\"mchoice$this->assign\" value=\"3\"><label style=\"margin-right: 3px\">3</label>";
		echo '</form>';
		echo '</div>';
		echo '</div>';
		echo '<div class="col-xs-7 col-sm-7 col-md-8 col-lg-10">';
		echo "<p>$this->question<br>";
		echo "<sub>Question $this->num in database</sub></p>";
		echo '</div>';
		echo '</div>'."\n";
	}
}
?>
