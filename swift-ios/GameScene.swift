import SpriteKit
import UIKit

class GameScene: SKScene {
    weak var model: GameModel?

    private var invaderNodes: [SKNode] = []
    private var alertNode: SKLabelNode?
    private var celebrationEmitter: SKEmitterNode?

    override func didMove(to view: SKView) {
        // Match the web game's #1f2937 (rgb 31,41,55)
        backgroundColor = UIColor(red: 31.0/255.0, green: 41.0/255.0, blue: 55.0/255.0, alpha: 1.0)
    }

    func spawnInvader(value: Int, speed: CGFloat) {
        // Create pill background + label to mimic the web invader style
        let container = SKNode()
        let text = SKLabelNode(text: "\(value)")
        text.fontName = "Avenir-Black"
        text.fontSize = 24
        text.fontColor = .white
        text.horizontalAlignmentMode = .center
        text.verticalAlignmentMode = .center

        let paddingX: CGFloat = 16
        let paddingY: CGFloat = 8
        // estimate label width
        let labelWidth = CGFloat(text.frame.width) + paddingX * 2
        let bg = SKShapeNode(rectOf: CGSize(width: max(48, labelWidth), height: 40), cornerRadius: 12)
        bg.fillColor = .systemRed
        bg.strokeColor = .clear
        bg.zPosition = 4
        text.zPosition = 5
        container.addChild(bg)
        container.addChild(text)

        // random x within scene bounds
        let padding: CGFloat = 40
        let minX = padding
        let maxX = max(padding, size.width - padding)
        let x = CGFloat.random(in: minX...maxX)
        container.position = CGPoint(x: x, y: size.height + 40)
        container.zPosition = 5
        addChild(container)
        invaderNodes.append(container)

        // compute duration based on speed (pixels per second)
        let distance = size.height + 80
        let duration = TimeInterval(distance / max(10.0, speed))
        let move = SKAction.moveBy(x: 0, y: -distance, duration: duration)
        let remove = SKAction.run { [weak self, weak container] in
            guard let self = self, let container = container else { return }
            if let idx = self.invaderNodes.firstIndex(of: container) { self.invaderNodes.remove(at: idx) }
            container.removeFromParent()
            self.model?.scoreWrong += 1
        }
        container.run(SKAction.sequence([move, remove]))
    }

    func destroyInvader(matchingAnswer answer: Int, multiplier: Int) -> Bool {
        for node in invaderNodes {
            // label is child at zPosition 5
            if let label = node.children.compactMap({ $0 as? SKLabelNode }).first, let txt = label.text, let value = Int(txt) {
                if value * multiplier == answer {
                    node.removeAllActions()
                    let pop = SKAction.group([SKAction.scale(to: 0.1, duration: 0.15), SKAction.fadeOut(withDuration: 0.15)])
                    let remove = SKAction.run { [weak self, weak node] in
                        guard let self = self, let node = node else { return }
                        if let idx = self.invaderNodes.firstIndex(of: node) { self.invaderNodes.remove(at: idx) }
                        node.removeFromParent()
                    }
                    node.run(SKAction.sequence([pop, remove]))
                    return true
                }
            }
        }
        return false
    }

    func showAlert(message: String, type: String) {
        alertNode?.removeFromParent()
        let label = SKLabelNode(text: message)
        label.fontName = "Avenir-Black"
        label.fontSize = 28
        label.fontColor = .white
        label.zPosition = 90
        label.position = CGPoint(x: size.width/2, y: size.height * 0.55)
        let bg = SKShapeNode(rectOf: CGSize(width: label.frame.width + 40, height: 56), cornerRadius: 12)
        bg.fillColor = (type == "correct") ? .systemGreen : .systemRed
        bg.zPosition = 89
        bg.position = label.position
        addChild(bg)
        addChild(label)
        alertNode = label
        let seq = SKAction.sequence([SKAction.fadeIn(withDuration: 0.06), SKAction.wait(forDuration: 0.8), SKAction.fadeOut(withDuration: 0.15), SKAction.run { bg.removeFromParent(); label.removeFromParent() }])
        label.alpha = 0
        bg.alpha = 0
        label.run(seq)
        bg.run(seq)
    }

    func showGameOver() {
        // Simple fade overlay
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        overlay.fillColor = .black
        overlay.alpha = 0.0
        overlay.zPosition = 100
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(overlay)
        overlay.run(SKAction.fadeAlpha(to: 0.7, duration: 0.4))
    }
}

private extension UIColor {
    var uiColor: UIColor { return self }
}
