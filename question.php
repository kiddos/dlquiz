<?php
class Question {
	private static $count = 0;
	private $num;
	private $ans;
	private $question;
	private $assign;
	function __construct($num, $ans, $question, $assign) {
		$this->num = $num;
		$this->ans = $ans;
		$this->question = $question;
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
	function output() {
		echo '<div class="row">';
		echo '<div class="col-xs-4 col-sm-4 col-md-3 col-lg-2">';
		echo '<div class="form-group">';
		echo '<form class="form-group" action="" method="" accept-charset="utf-8" role="form">';
		echo "<label style=\"margin-right: 6px\"><em>$this->assign.</em></label>";
		echo "<input type=\"radio\" name=\"choice$assign\" value=\"O\" style=\"margin-right: 5px\"><label style=\"margin-right: 3px\">O</label>";
		echo "<input type=\"radio\" name=\"choice$assign\" value=\"X\" style=\"margin-right: 5px\"><label style=\"margin-right: 3px\">X</label>";
		echo '</form>';
		echo '</div>';
		echo '</div>';
		echo '<div class="col-xs-8 col-sm-8 col-md-9 col-lg-10">';
		echo "<p>$this->question<br>";
		echo "<sub>Question $this->num in database</sub></p>";
		echo '</div>';
		echo '</div>'."\n";
	}
}
?>
