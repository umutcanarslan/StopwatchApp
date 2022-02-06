//
//  ViewController.swift
//  StopwatchApp
//
//  Created by Umut Can Arslan on 22.01.2022.
//
//  States;     Left Button             Right Button            Counter
//
//  Idle:      Lap(Disabled)                Start                  nil
//  Counting:      Lap                      Stop                 xx:xx:x0
//  Paused:       Reset                    Continue              xx:xx:xx
//


import UIKit

class ViewController: UIViewController {

    enum CounterState {
        case idle, counting, paused
    }

    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var lapResetButton: UIButton!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var lapLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lapTitleLabelCell: UILabel!
    @IBOutlet weak var lapCountLabelCell: UILabel!

    private let startColor = UIColor.init(red: 52/255, green: 168/255, blue: 83/255, alpha: 0.3)
    private let stopColor = UIColor.init(red: 234/255, green: 67/255, blue: 34/255, alpha: 0.3)
    private let LapColor = UIColor.init(red: 44/255, green: 39/255, blue: 51/255, alpha: 0.8)
    private let LapColorDisabled = UIColor.init(red: 44/255, green: 39/255, blue: 51/255, alpha: 0.3)
    private let resetColor = UIColor.init(red: 44/255, green: 39/255, blue: 51/255, alpha: 0.8)

    var mainTimer: Timer?
    var lapTimer: Timer?
    var mainCounter = 0
    var lapCounter = 0
    var currentLap = 0
    var laps: [LapModel] = []

    var state: CounterState = .idle {
        didSet {
            updateUI(with: state)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(with: .idle)
    }

    @IBAction func startStopButtonTapped(_ sender: Any) {
        switch state {
            case .idle:
                currentLap = 1
                mainTimer = Timer.scheduledTimer(
                    timeInterval: 1/60,
                    target: self,
                    selector: #selector(counterLabelUpdate),
                    userInfo: nil,
                    repeats: true
                )
                lapTimer = Timer.scheduledTimer(
                    timeInterval: 1/60,
                    target: self,
                    selector: #selector(lapLabelUpdate),
                    userInfo: nil,
                    repeats: true
                )
                state = .counting
            case .counting:
                mainTimer?.invalidate()
                lapTimer?.invalidate()
                state = .paused
            case .paused:
                mainTimer = Timer.scheduledTimer(
                    timeInterval: 1/60,
                    target: self,
                    selector: #selector(counterLabelUpdate),
                    userInfo: nil,
                    repeats: true
                )
                lapTimer = Timer.scheduledTimer(
                    timeInterval: 1/60,
                    target: self,
                    selector: #selector(lapLabelUpdate),
                    userInfo: nil,
                    repeats: true
                )
                state = .counting
        }
    }

    @IBAction func lapResetButtonTapped(_ sender: Any) {
        switch state {
            case .idle:
                // herhangi bir fonksiyon yok
                break
            case .counting:
                let currentLapText = "Lap " + "\(currentLap)"
                let lap = LapModel(
                    lapCount: currentLapText,
                    lapCounter: lapCounter.counterTimerFormat()
                )
                laps.insert(lap, at: 0)
                tableView.reloadData()

                lapTimer?.invalidate()
                lapCounter = 0
                currentLap += 1
                lapLabel.text = "Lap " + "\(currentLap)" + ": " + lapCounter.counterTimerFormat()
                lapTimer = Timer.scheduledTimer(
                    timeInterval: 1/60,
                    target: self,
                    selector: #selector(lapLabelUpdate),
                    userInfo: nil,
                    repeats: true
                )

            case .paused:
                // resetleme
                mainTimer?.invalidate()
                lapTimer?.invalidate()
                laps = []
                tableView.reloadData()
                state = .idle
        }
    }

    @objc private func counterLabelUpdate() {
        mainCounter += 1
        counterLabel.text = mainCounter.counterTimerFormat()
    }

    @objc private func lapLabelUpdate() {
        lapCounter += 1
        lapLabel.text = "Lap: " + lapCounter.counterTimerFormat()


    }

}

extension ViewController {

    func setupUI() {
        tableView.dataSource = self
        startStopButton.layer.cornerRadius = 48
        startStopButton.setTitleColor(.white, for: .normal)
        lapResetButton.layer.cornerRadius = 48
        lapResetButton.setTitleColor(.white, for: .normal)
    }

    func updateUI(with state: CounterState) {
        switch state {
            case .idle:
                mainCounter = 0
                lapCounter = 0
                currentLap = 0
                counterLabel.text = 0.counterTimerFormat()
                lapLabel.text = "Lap: " + 0.counterTimerFormat()
                startStopButton.backgroundColor = startColor
                startStopButton.setTitle("Start", for: .normal)
                startStopButton.setTitleColor(.green, for: .normal)
                lapResetButton.backgroundColor = LapColorDisabled
                lapResetButton.setTitle("Lap", for: .normal)
                lapResetButton.isEnabled = false

            case .counting:
                lapResetButton.isEnabled = true
                startStopButton.backgroundColor = stopColor
                startStopButton.setTitle("Stop", for: .normal)
                startStopButton.setTitleColor(.red, for: .normal)
                lapResetButton.backgroundColor = LapColor
                lapResetButton.setTitle("Lap", for: .normal)
                lapResetButton.setTitleColor(.white, for: .normal)
            case .paused:
                startStopButton.backgroundColor = startColor
                startStopButton.setTitle("Continue", for: .normal)
                startStopButton.setTitleColor(.green, for: .normal)
                lapResetButton.backgroundColor = resetColor
                lapResetButton.setTitle("Reset", for: .normal)
                lapResetButton.setTitleColor(.white, for: .normal)
        }
    }

}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection: Int) -> Int {
        return laps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LapTableViewCell",
                for: indexPath
            ) as? LapTableViewCell
        else {
                return UITableViewCell()
            }
        let lap = laps[indexPath.row]
        cell.lapTitleLabel.text = lap.lapCount
        cell.lapCounterLabel.text = lap.lapCounter

        return cell
    }

}
