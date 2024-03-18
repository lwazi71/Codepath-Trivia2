import UIKit

class TriviaViewController: UIViewController {

    @IBOutlet weak var currentQuestionNumberLabel: UILabel!
    @IBOutlet weak var questionContainerView: UIView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var answerButton0: UIButton!
    @IBOutlet weak var answerButton1: UIButton!
    @IBOutlet weak var answerButton2: UIButton!
    @IBOutlet weak var answerButton3: UIButton!
    @IBOutlet weak var categoryPicker: UIPickerView!

    private var questions = [[String: Any]]()
    private var currQuestionIndex = 0
    private var numCorrectQuestions = 0
    private let triviaQuestionService = TriviaQuestionService()
    private var selectedCategory: String?
    private var selectedDifficulty: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        questionContainerView.layer.cornerRadius = 8.0
        fetchTriviaQuestions()
    }

    private func fetchTriviaQuestions() {
        triviaQuestionService.fetchTriviaQuestions { [weak self] triviaQuestions, error in
            guard let self = self else { return }

            if let triviaQuestions = triviaQuestions {
                self.questions = triviaQuestions
                self.currQuestionIndex = 0
                DispatchQueue.main.async {
                    self.updateQuestion(withQuestionIndex: self.currQuestionIndex)
                }
            } else if let error = error {
                print("Error fetching trivia questions: \(error)")
            }
        }
    }
    private func decodeHTMLString(_ string: String) -> String? {
         guard let data = string.data(using: .utf8) else {
             return nil
         }
         let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
             .documentType: NSAttributedString.DocumentType.html,
             .characterEncoding: String.Encoding.utf8.rawValue
         ]
         do {
             let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
             return attributedString.string
         } catch {
             print("Error decoding HTML string: \(error)")
             return nil
         }
     }

    private func updateQuestion(withQuestionIndex questionIndex: Int) {
        currentQuestionNumberLabel.text = "Question: \(questionIndex + 1)/\(questions.count)"
        let question = questions[questionIndex]
        
        // Decode HTML entities in the question text
        if let questionText = question["question"] as? String,
           let decodedQuestionText = decodeHTMLString(questionText) {
            questionLabel.text = decodedQuestionText
        } else {
            questionLabel.text = "Invalid question"
        }
        
        // Set category label
        if let categoryText = question["category"] as? String,
           let decodedCategoryText = decodeHTMLString(categoryText) {
            categoryLabel.text = decodedCategoryText
        } else {
            categoryLabel.text = "Invalid category"
        }
        
        // Set answer buttons
        let answers = ([question["correct_answer"]] as? [String] ?? []) + (question["incorrect_answers"] as? [String] ?? [])
        let shuffledAnswers = answers.shuffled()
        
        for (index, button) in [answerButton0, answerButton1, answerButton2, answerButton3].enumerated() {
            if index < shuffledAnswers.count {
                if let answerText = shuffledAnswers[index] as? String {
                    let decodedAnswerText = decodeHTMLString(answerText) ?? "Invalid answer"
                    button?.setTitle(decodedAnswerText, for: .normal)
                    button?.isHidden = false
                } else {
                    button?.setTitle("", for: .normal)
                    button?.isHidden = true
                }
            } else {
                button?.setTitle("", for: .normal)
                button?.isHidden = true
            }
        }
    }

    private func updateToNextQuestion(answer: String) {
        if isCorrectAnswer(answer) {
            numCorrectQuestions += 1
        }
        currQuestionIndex += 1
        guard currQuestionIndex < questions.count else {
            showFinalScore()
            return
        }
        updateQuestion(withQuestionIndex: currQuestionIndex)
    }

    private func isCorrectAnswer(_ answer: String) -> Bool {
        return answer == (questions[currQuestionIndex]["correct_answer"] as? String ?? "")
    }

    private func showFinalScore() {
        let alertController = UIAlertController(title: "Game over!",
                                                message: "Final score: \(numCorrectQuestions)/\(questions.count)",
                                                preferredStyle: .alert)

        let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.resetGame()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(restartAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func resetGame() {
        currQuestionIndex = 0
        numCorrectQuestions = 0
        fetchTriviaQuestions()
    }

    private func addGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [UIColor(red: 0.54, green: 0.88, blue: 0.99, alpha: 1.00).cgColor,
                                UIColor(red: 0.51, green: 0.81, blue: 0.97, alpha: 1.00).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func didTapAnswerButton0(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    @IBAction func didTapAnswerButton1(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    @IBAction func didTapAnswerButton2(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }

    @IBAction func didTapAnswerButton3(_ sender: UIButton) {
        updateToNextQuestion(answer: sender.titleLabel?.text ?? "")
    }
}

