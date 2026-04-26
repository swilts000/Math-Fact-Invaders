import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var model = GameModel()
    @State private var showSettings = true
    @State private var fixedMultiplier: Int? = nil
    @State private var showGameOver = false
    @State private var wasRunning = false

    var scene: GameScene {
        let s = GameScene()
        s.size = CGSize(width: 350, height: 600)
        s.scaleMode = .resizeFill
        s.model = model
        model.scene = s
        return s
    }

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                if showSettings {
                    settingsView
                } else {
                    gameView
                }
            }
            if showGameOver {
                Color.black.opacity(0.45).edgesIgnoringSafeArea(.all)
                gameOverView
            }
        }
        .padding()
        .onReceive(model.$isRunning) { running in
            if wasRunning && !running {
                // game finished
                showGameOver = true
            }
            wasRunning = running
            if !running { showSettings = true }
        }
    }

    var settingsView: some View {
        VStack(spacing: 12) {
            Text("Math Fact Invaders").font(.largeTitle).bold()
            Picker("Difficulty", selection: Binding(get: { model.difficultySingle }, set: { model.difficultySingle = $0 })) {
                Text("Single").tag(true)
                Text("Double").tag(false)
            }.pickerStyle(SegmentedPickerStyle())

            Picker("Speed", selection: $model.speed) {
                Text("Easy").tag("easy")
                Text("Intermediate").tag("intermediate")
                Text("Fast").tag("fast")
            }.pickerStyle(SegmentedPickerStyle())

            Picker("Mode", selection: Binding(get: { model.mode == .time ? 0 : 1 }, set: { model.mode = $0==0 ? .time : .score })) {
                Text("Timed").tag(0)
                Text("Score").tag(1)
            }.pickerStyle(SegmentedPickerStyle())

            HStack {
                Text("Limit")
                Spacer()
                TextField("Limit", value: Binding(get: { model.limit }, set: { model.limit = $0 }), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }

            HStack {
                Text("Fixed Multiplier (optional)")
                Spacer()
                TextField("7", value: Binding(get: { fixedMultiplier ?? 7 }, set: { fixedMultiplier = $0 }), formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }

            Button(action: {
                model.setSettings(difficultySingle: model.difficultySingle, speed: model.speed, mode: model.mode, limit: model.limit, multiplierModeFixed: fixedMultiplier)
                model.start()
                showSettings = false
            }) {
                Text("Start Game").font(.title2).bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
        }
    }

    var gameView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack { Text("RIGHT").font(.caption); Text("\(model.scoreRight)").font(.title).foregroundColor(.green) }
                Spacer()
                Text(model.mode == .time ? "Time: \(model.timeLeft)s" : "Score: \(model.scoreRight) / \(model.limit)")
                    .font(.title2)
                Spacer()
                VStack { Text("WRONG").font(.caption); Text("\(model.scoreWrong)").font(.title).foregroundColor(.red) }
            }

            ZStack {
                SpriteView(scene: scene)
                    .frame(height: 450)
                    .cornerRadius(12)
                    .shadow(radius: 4)

                Text("× \(model.multiplier)")
                    .font(.system(size: 100, weight: .black))
                    .foregroundColor(Color(red: 0.82, green: 0.83, blue: 0.86))
                    .allowsHitTesting(false)
            }

                Text(model.currentAnswer.isEmpty ? "0" : model.currentAnswer)
                    .font(.system(size: 34, weight: .heavy))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)

            keypad
        }
    }

    var keypad: some View {
        let keys = [["1","2","3"],["4","5","6"],["7","8","9"],["del","0","submit"]]
        return VStack(spacing: 8) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(row, id: \.self) { key in
                        Button(action: { model.handleKey(key) }) {
                            Text(key == "del" ? "DEL" : (key == "submit" ? "✓ GO" : key))
                                .font(.system(size: 22, weight: .bold))
                                .frame(maxWidth: .infinity, minHeight: 64)
                                .background(key == "del" ? Color(red: 239/255, green: 68/255, blue: 68/255) : (key=="submit" ? Color(red: 16/255, green: 163/255, blue: 74/255) : Color.white))
                                .foregroundColor(key == "del" || key == "submit" ? .white : .black)
                                .cornerRadius(12)
                                .shadow(radius: 2)
                        }
                    }
                }
            }
        }
    }

    var gameOverView: some View {
        VStack(spacing: 16) {
            Text(model.scoreWrong > model.scoreRight ? "You Lost!" : "You Win!")
                .font(.largeTitle).bold().foregroundColor(.white)
            HStack(spacing: 24) {
                VStack { Text("Final Score (Right)").foregroundColor(.white); Text("\(model.scoreRight)").font(.largeTitle).bold().foregroundColor(.green) }
                VStack { Text("Final Score (Wrong)").foregroundColor(.white); Text("\(model.scoreWrong)").font(.largeTitle).bold().foregroundColor(.red) }
            }
            Button(action: {
                // restart: show settings
                showGameOver = false
                showSettings = true
            }) {
                Text("Play Again").bold().frame(maxWidth: .infinity).padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
            }
        }
        .padding(24)
        .background(Color(UIColor.systemGray).opacity(0.95))
        .cornerRadius(14)
        .frame(maxWidth: 520)
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
