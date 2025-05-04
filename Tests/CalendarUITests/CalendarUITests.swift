//
//  CalendarUITests.swift
//  CalendarUITests
//
//  Created by Jakob Jacobsen on 5/3/25.
//

import XCTest

private extension Date { var long: String { formatted(date: .long, time: .omitted) } }

private extension XCUIElement {
    func clearAndType(_ s: String) {
        tap()
        if let v = value as? String {
            typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: v.count))
        }
        typeText(s)
    }
}

private extension XCUIApplication {

    func elementBeginning(with prefix: String,
                          timeout: TimeInterval = 2) -> XCUIElement {
        let pred = NSPredicate(format: "identifier BEGINSWITH %@", prefix)
        let el   = descendants(matching: .any).matching(pred).firstMatch
        XCTAssertTrue(el.waitForExistence(timeout: timeout),
                      "No element whose id begins with “\(prefix)”")
        return el
    }

    func buttonBeginning(with prefix: String,
                         timeout: TimeInterval = 2) -> XCUIElement {
        elementBeginning(with: prefix, timeout: timeout)
    }

    func scrollUntilVisible(_ el: XCUIElement,
                            max: Int = 6,
                            file: StaticString = #file,
                            line: UInt = #line) {
        var n = 0
        while !el.exists && n < max { swipeUp(); n += 1 }
        XCTAssertTrue(el.exists,
                      "Element \(el) not found after scrolling",
                      file: file, line: line)
    }
}

// ───────── Test-case
final class CalendarUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false;
        //force portrait before launch
        let device = XCUIDevice.shared
           if device.orientation != .portrait {
               device.orientation = .portrait
           }
        app.launch()
    }

    // Delete all button
    func testDeleteAllEventsButtonClearsStore() {
        addEvent(title: "One")
        addEvent(title: "Two")

        if app.buttons["Back"].exists { app.buttons["Back"].tap() }

        let delAll = app.buttons["deleteAllEventsButton"]
        XCTAssertTrue(delAll.exists)
        delAll.tap()

        app.buttonBeginning(with: "monthDate_\(Date().long)").tap()
        XCTAssertFalse(app.staticTexts["One"].exists)
        XCTAssertFalse(app.staticTexts["Two"].exists)
    }

    
    // Add event
    func testAddEventShowsInList() {
        addEvent(title: "Exam 📝")
        XCTAssertTrue(app.staticTexts["Exam 📝"].waitForExistence(timeout: 2))
    }

    //  Grid → DayView
    func testTapMonthDateOpensDayView() {
        app.buttonBeginning(with: "monthDate_May 4, 2025").tap()
        XCTAssertTrue(app.navigationBars["May 4, 2025"].waitForExistence(timeout: 2))
    }

    // Toggle Month ⇄ Week
    func testToggleWeekView() {
        let toggle = app.buttons["toggleViewModeButton"]
        app.scrollUntilVisible(toggle); toggle.tap()                         // Month → Week
        XCTAssertTrue(app.buttonBeginning(with: "weekDate_\(Date().long)").exists)
        app.scrollUntilVisible(toggle); toggle.tap()                         // Week → Month
        XCTAssertTrue(app.buttonBeginning(with: "monthDate_\(Date().long)").exists)
    }

    // Edit title
    func testEditEventUpdatesRow() {
        addEvent(title: "Old")
        rowLabeled("Old").tap()
        app.textFields["eventTitleField"].clearAndType("New")
        app.buttons["saveEventButton"].tap()
        XCTAssertTrue(rowLabeled("New").waitForExistence(timeout: 2))
    }

    //Swipe-delete
    func testDeleteEventWithSwipe() {
        addEvent(title: "Swipe delete")
        let row = rowLabeled("Swipe delete")
        row.swipeLeft()
        let deleteBtn = app.buttons["Delete"].firstMatch
        XCTAssertTrue(deleteBtn.waitForExistence(timeout: 1))
        deleteBtn.tap()
        
        app.buttons["deleteSingleButton"].tap()
        
        XCTAssertFalse(row.waitForExistence(timeout: 1))
    }

    // Delete via dialog
    func testDeleteEventFromEditDialog() {
        addEvent(title: "RemoveMe")
        rowLabeled("RemoveMe").tap()
        let delRow = app.buttons["deleteEventButton"]
        app.scrollUntilVisible(delRow); delRow.tap()
        app.buttons["deleteSingleButton"].tap()
        XCTAssertFalse(rowLabeled("RemoveMe").waitForExistence(timeout: 1))
    }

    // Recurring split-save
    func testRecurringSplitSave() {
        addEvent(title: "Weekly", recurrence: "Weekly")
        rowLabeled("Weekly").tap()
        app.textFields["eventTitleField"].clearAndType("Just This")
        app.buttons["saveEventButton"].tap()
        app.buttons["saveOccurrenceButton"].tap()
        XCTAssertTrue(rowLabeled("Just This").waitForExistence(timeout: 2))
    }

    // Toggle notifications
    func testToggleNotifications() {
        addEvent(title: "Notify")
        rowLabeled("Notify").tap()
        let t = app.switches["notificationsToggle"]; XCTAssertTrue(t.exists); t.tap()
        app.buttons["saveEventButton"].tap()
    }

    // helper - locate a row by prefix
    private func rowLabeled(_ title: String) -> XCUIElement {
        let p = NSPredicate(format: "label BEGINSWITH %@", title)
        return app.staticTexts.element(matching: p)
    }

    // helper - add an event
    private func addEvent(title: String,
                          recurrence: String? = nil,
                          file: StaticString = #file, line: UInt = #line) {

        if !app.buttons["addEventButton"].exists {
            app.buttonBeginning(with: "monthDate_\(Date().long)").tap()
        }
        app.buttons["addEventButton"].tap()

        let tf = app.textFields["eventTitleField"]
        XCTAssertTrue(tf.waitForExistence(timeout: 2), file: file, line: line)
        tf.tap(); tf.typeText(title)

        if let rec = recurrence {
            let recButton = app.buttons["recurrencePicker"]
            app.scrollUntilVisible(recButton)
            recButton.tap()
            app.buttons[rec].tap()
        }

        app.buttons["saveEventButton"].tap()
        XCTAssertTrue(rowLabeled(title).waitForExistence(timeout: 2),
                      "Row '\(title)' not visible",
                      file: file, line: line)
    }
    
    override func tearDown() {
        
        if app.buttons["deleteAllEventsButton"].exists == false,
           app.buttons["Back"].exists {
            app.buttons["Back"].tap()
        }
        //   use delete all button
        if app.buttons["deleteAllEventsButton"].exists {
            app.buttons["deleteAllEventsButton"].tap()
        }
        super.tearDown()
    }

}


