//
//  TimerFormat.swift
//  StopwatchApp
//
//  Created by Umut Can Arslan on 22.01.2022.
//

import Foundation

extension Int {

    func counterTimerFormat() -> String {

        var seconds = 0
        var minutes = 0
        var hours = 0
        var split = 0

        hours = self / 216000
        minutes = self / 3600
        seconds = (self % 3600) / 60
        split = (self % 60) % 60


        return String(format: "%02i:%02i:%02i:%02i", hours, minutes, seconds, split)
    }

}
