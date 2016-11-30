//
//  TimeEditPresenter.swift
//  Freelancer
//
//  Created by Denys Meloshyn on 29/11/2016.
//  Copyright © 2016 Denys Meloshyn. All rights reserved.
//

import UIKit
import CoreData

enum TimerState {
    case none
    case run
    case pause
    case increaseManually
    case decreaseManually
}

protocol TimeEditPresenterDelegate: class {
    func showSaveButton()
    func showApplyButton()
    func showTimeReport(_ time: String?)
    func showTimeReportTitle(_ title: String?)
    func updateResumePauseButtonTitle(_ title: String)
    func updateDatepickerWithVisibility(_ visible: Bool)
}

class TimeEditPresenter: NSObject, LifeCycleStateProtocol {
    private var timer: Timer?
    private var timerState = TimerState.pause

    var currentTimeID: NSManagedObjectID?
    var currentProjectID: NSManagedObjectID?
    weak var viewController: UIViewController?
    weak var interaction: TimeEditInteraction?
    weak var delegate: TimeEditPresenterDelegate?

    func configure(with interaction: TimeEditInteraction?) {
        self.interaction = interaction
    }

    func initialConfiguration() {
        self.interaction?.currentTimeID = self.currentTimeID
        self.interaction?.currentProjectID = self.currentProjectID
        self.interaction?.initialConfiguration()

        self.delegate?.showSaveButton()
        self.delegate?.showTimeReportTitle(self.interaction?.currentTime?.title)
        self.updateTime()
        self.updateRunButtonTitle()
    }
    
    func titleValueEdited(sender: UITextField?) {
        self.interaction?.currentTime?.title = sender?.text
    }

    func saveChanges() {
        self.interaction?.saveTimeEditChanges()
    }

    func runStopTimer() {
        switch self.timerState {
        case .run:
            self.stopTimer()
            
        case .pause:
            self.runTimer()
            
        default:
            break
        }
        
        self.updateRunButtonTitle()
    }
    
    func increaseButtonHandler() {
        self.stopTimer()

        self.timerState = .increaseManually
        self.delegate?.updateDatepickerWithVisibility(true)
        self.delegate?.showApplyButton()
    }
    
    func decreaseButtonHandler() {
        self.stopTimer()

        self.timerState = .decreaseManually
        self.delegate?.updateDatepickerWithVisibility(true)
        self.delegate?.showApplyButton()
    }

    func applyManualChanges() {
        self.hideDatePicker()
    }

    func hideDatePicker() {
        self.timerState = .pause
        self.delegate?.updateDatepickerWithVisibility(false)
        self.delegate?.showSaveButton()
    }

    // MARK: - LifeCycleStateProtocol methods

    func viewWillAppear(_ animated: Bool) {

    }

    func viewDidAppear(_ animated: Bool) {

    }

    func viewWillDisappear(_ animated: Bool) {
        self.timer?.invalidate()
    }

    func viewDidDisappear(_ animated: Bool) {

    }

    // MARK: - Private methods

    private func stopTimer() {
        self.timerState = .pause
        self.timer?.invalidate()
        self.updateRunButtonTitle()
    }
    
    private func runTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {[weak self] timer in
            self?.interaction?.increaseTimeOneSecond()
            self?.updateTime()
        })
    }
    
    private func updateTime() {
        var time = ""
        let calendar = Calendar.current
        
        if let dateComponents = self.interaction?.currentTime?.spent(), let date = calendar.date(from: dateComponents) {
            let formatter = Constants.defaultDateFormatter()
            time = formatter.string(from: date)
        }
        
        self.delegate?.showTimeReport(time)
    }
    
    private func updateRunButtonTitle() {
        switch self.timerState {
        case .run:
            self.delegate?.updateResumePauseButtonTitle("Pause")
            
        case .pause:
            if let dateComponents = self.interaction?.currentTime?.spent(), dateComponents.second == 0 && dateComponents.minute == 0 && dateComponents.hour == 0 {
                self.delegate?.updateResumePauseButtonTitle("Start")
            } else {
                self.delegate?.updateResumePauseButtonTitle("Resume")
            }
        default:
            break
        }
    }
}
