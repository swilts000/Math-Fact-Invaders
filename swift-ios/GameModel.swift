import Foundation
import Combine
import SpriteKit

final class GameModel: ObservableObject {
    enum Mode { case time, score }

    // Published UI state
    @Published var scoreRight = 0
    @Published var scoreWrong = 0
    @Published var timeLeft: Int = 60
    @Published var multiplier: Int = 2
    @Published var alertMessage: String = ""
    @Published var alertType: String = ""
    @Published var currentAnswer: String = ""
    @Published var isRunning: Bool = false

    // Settings
    var difficultySingle = true
    var speed: String = "intermediate" // easy/intermediate/fast
    var mode: Mode = .time
    var limit: Int = 60
    var multiplierIsFixed: Bool = false

    // Scene bridge
    weak var scene: GameScene?

    private var spawnTimer: Timer?
    private var gameTimer: Timer?
    private var spawnInterval: TimeInterval = 2.5
    private var lastSpawnTime: Date? = nil

    func setSettings(difficultySingle: Bool, speed: String, mode: Mode, limit: Int, multiplierModeFixed: Int?) {
        self.difficultySingle = difficultySingle
        self.speed = speed
        self.mode = mode
        self.limit = limit
        if let fixed = multiplierModeFixed { self.multiplier = fixed; self.multiplierIsFixed = true } else { self.multiplierIsFixed = false }
    }

    func start() {
        scoreRight = 0
        scoreWrong = 0
        currentAnswer = ""
        isRunning = true
        timeLeft = (mode == .time) ? limit : 0
        // set multiplier: if fixed was provided keep it, otherwise random based on difficulty
        if !multiplierIsFixed {
            multiplier = difficultySingle ? Int.random(in: 1...9) : Int.random(in: 1...12)
        }

        // Spawn cadence (use a short repeating timer that checks elapsed time so we can adjust interval)
        spawnInterval = 2.5
        lastSpawnTime = Date().addingTimeInterval(-spawnInterval)
        spawnTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let now = Date()
            if let last = self.lastSpawnTime, now.timeIntervalSince(last) >= self.spawnInterval {
                self.spawnInvader()
                self.lastSpawnTime = now
                // accelerate spawn interval down to a floor like web
                self.spawnInterval = max(0.6, self.spawnInterval - 0.05)
            }
        }

        gameTimer?.invalidate()
        if mode == .time {
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                self.timeLeft -= 1
                if self.timeLeft <= 0 { self.endGame(didWin: true) }
            }
        }
    }

    func stop() {
        spawnTimer?.invalidate(); spawnTimer = nil
        gameTimer?.invalidate(); gameTimer = nil
        isRunning = false
    }

    func spawnInvader() {
        let value: Int
        if difficultySingle { value = Int.random(in: 1...9) }
        else { value = Int.random(in: 10...99) }
        let speedValue: CGFloat
        switch speed {
        case "easy": speedValue = CGFloat(Double.random(in: 30...60))
        case "fast": speedValue = CGFloat(Double.random(in: 110...180))
        default: speedValue = CGFloat(Double.random(in: 60...120))
        }
        scene?.spawnInvader(value: value, speed: speedValue)
    }

    func handleKey(_ key: String) {
        guard isRunning else { return }
        if key == "del" {
            currentAnswer = String(currentAnswer.dropLast())
        } else if key == "submit" {
            checkAnswer()
        } else { // digit
            if currentAnswer.count < 6 { currentAnswer.append(key) }
        }
    }

    func checkAnswer() {
        guard let answer = Int(currentAnswer) else { currentAnswer = ""; return }
        let hit = scene?.destroyInvader(matchingAnswer: answer, multiplier: multiplier) ?? false
        if hit {
            scoreRight += 1
            alertMessage = "Correct!"
            alertType = "correct"
            // if in score mode, check win
            if mode == .score && scoreRight >= limit { endGame(didWin: true); return }
        } else {
            scoreWrong += 1
            alertMessage = "Wrong!"
            alertType = "wrong"
        }
        // let the scene show the alert visually
        if let s = scene { s.showAlert(message: alertMessage, type: alertType) }
        currentAnswer = ""
    }

    func endGame(didWin: Bool) {
        stop()
        isRunning = false
        // Notify scene to show end state
        scene?.showGameOver()
    }
}
