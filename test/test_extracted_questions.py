import unittest
import os
import json

class TestExtractedQuestions(unittest.TestCase):
    BASE_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "questions", "v2")

    DATASETS = [
        ("car", "zh", 1090),
        ("car", "en", 1090),
        ("motorcycle", "zh", 806),
        ("motorcycle", "en", 806)
    ]

    def test_extracted_questions_format_and_counts(self):
        for vehicle, lang, expected_count in self.DATASETS:
            dataset_dir = os.path.join(self.BASE_DIR, vehicle, lang)
            json_path = os.path.join(dataset_dir, "questions.json")
            txt_path = os.path.join(dataset_dir, "questions.txt")
            img_dir = os.path.join(dataset_dir, "images")

            self.assertTrue(os.path.exists(json_path), f"JSON file missing for {vehicle}/{lang}")
            self.assertTrue(os.path.exists(txt_path), f"TXT file missing for {vehicle}/{lang}")
            self.assertTrue(os.path.exists(img_dir), f"Images directory missing for {vehicle}/{lang}")

            with open(json_path, "r", encoding="utf-8") as f:
                questions = json.load(f)

            self.assertEqual(len(questions), expected_count, f"Question count mismatch for {vehicle}/{lang}")

            qnums = [q["num"] for q in questions]
            self.assertEqual(qnums, list(range(1, expected_count + 1)), f"Question numbers not sequential for {vehicle}/{lang}")

            for q in questions:
                self.assertIn("num", q)
                self.assertIn("answer", q)
                self.assertIn("text", q)
                self.assertIn("options", q)
                self.assertIn("images", q)
                self.assertIn("architecture", q)

                self.assertIn(q["answer"], ["1", "2", "3", "O", "X"], f"Invalid answer '{q['answer']}' in {vehicle}/{lang} Q{q['num']}")
                self.assertTrue(len(q["text"]) > 0, f"Empty text in {vehicle}/{lang} Q{q['num']}")
                self.assertTrue(len(q["architecture"]) > 0, f"Empty architecture in {vehicle}/{lang} Q{q['num']}")

                for img_rel in q["images"]:
                    img_full = os.path.join(dataset_dir, img_rel)
                    self.assertTrue(os.path.exists(img_full), f"Missing image file {img_full} referenced in {vehicle}/{lang} Q{q['num']}")

    def test_questions_txt_line_count(self):
        for vehicle, lang, expected_count in self.DATASETS:
            txt_path = os.path.join(self.BASE_DIR, vehicle, lang, "questions.txt")
            with open(txt_path, "r", encoding="utf-8") as f:
                lines = [line.strip() for line in f if line.strip()]
            self.assertEqual(len(lines), expected_count, f"Line count in questions.txt mismatch for {vehicle}/{lang}")

if __name__ == "__main__":
    unittest.main()
