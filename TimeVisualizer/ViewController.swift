//
//  ViewController.swift
//  TimeVisualizer
//
//  Created by Maha saad on 20/05/1443 AH.
//

import UIKit
import CalendarKit
import CoreData

struct TimeEvent{
    var eventText : String
    var startDate : Date
    var endDate : Date
}

class ViewController: DayViewController {
    var colors = [UIColor.systemMint,
                    UIColor.systemCyan,
                  UIColor.systemGreen,
                    UIColor.systemYellow]
    var events = [EventDescriptor]()
    //save data core data
    var timeEvents = [EventEntity]()
    private var createdEvent: EventDescriptor?
    private var createdTimeEvent: EventEntity?
    private lazy var rangeFormatter: DateIntervalFormatter = {
        let fmt = DateIntervalFormatter()
        fmt.dateStyle = .none
        fmt.timeStyle = .short
        return fmt
      }()
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadData()
        navigationController?.navigationBar.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
    }
    // Return an array of EventDescriptors for particular date
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let timeEvents = getAllEvents()
        var events:[EventDescriptor] = []
        for timeEvent in timeEvents {
            let event = Event()
            guard let startDate = timeEvent.startDate, let endDate = timeEvent.endDate, let text = timeEvent.eventText else{
                return []
            }
            event.dateInterval = DateInterval(start: startDate, end: endDate)
            //var info = ["New event", "Studing algorithims", "San Francisco"]
            //info.append(rangeFormatter.string(from: event.dateInterval)!)
            //event.text = info.reduce("", {$0 + $1 + "\n"})
            event.text = text
            event.textColor = .secondarySystemBackground
            event.color = colors[Int(timeEvent.colorlandex)]
            events.append(event)
        }
        self.events = events
        return events
    }
    @IBAction func progessButtonTapped(_ sender: UIBarButtonItem) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "GraphViewController") as! GraphViewController
        vc.events = events
        
        navigationController?.pushViewController(vc, animated: true)
    }
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        
        endEventEditing()
        
        let alert = UIAlertController(title: "Add New Item", message: "What are you studying?", preferredStyle: .alert)
        
        alert.addTextField { field in
            field.placeholder = "Event Name"
        }
        
        let alertAction = UIAlertAction(title: "Done", style: .destructive) { _ in
            guard let text = alert.textFields?[0].text else {
                return
            }
            let colorIndex = Int.random(in: 0..<self.colors.count)
            let newEvent = self.createNewEvent(at: date, text: text, colorIndex: colorIndex)
            let newTimeEvent = self.createTimeEvent(at: date, text: text, colorIndex: colorIndex)
            self.create(event: newEvent, animated: true)
            self.createdEvent = newEvent
            self.createdTimeEvent = newTimeEvent
        }
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        guard let descriptor = eventView.descriptor else {
            return
        }
        let context = getUpdatedContext()
        
        events.removeAll { event in
            event === descriptor
        }
        
        
        var index = 0
        for i in 0..<timeEvents.count {
            if DateInterval(start: timeEvents[i].startDate!, end: timeEvents[i].endDate!) == descriptor.dateInterval{
                context.delete(timeEvents[i])
                index = i
            }
        }
        timeEvents.remove(at: index)
        saveContext()
        
        reloadData()
        
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
        print("DayView did begin dragging")
      }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
        print("Did Tap at date: \(date)")
      }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
      //  guard let descriptor = eventView.descriptor as? Event else {
    //        return
   //     }
        endEventEditing()
//        print("Event has been longPressed: \(descriptor) \(String(describing: descriptor.userInfo))")
//        beginEditing(event: descriptor, animated: true)
    }
    
    //create events
    func createNewEvent(at date: Date, text: String, colorIndex: Int) -> EventDescriptor{
        let event = Event()
        let endDate = date.addingTimeInterval(60*60)
        event.dateInterval = DateInterval(start: date, end: endDate)
        event.text = text
        event.textColor = .secondarySystemBackground
        event.color = colors[colorIndex]
        event.editedEvent = event
        return event
    }
    override func dayView(dayView: DayView, didUpdate event: EventDescriptor) {
        print("did finish editing \(event)")
        print("new startDate: \(event.dateInterval.start) new endDate: \(event.dateInterval.end)")
        
        if let _ = event.editedEvent {
            print("event.editedEvent")
            event.commitEditing()
        }
        
        if let createdEvent = createdEvent, let createdTimeEvent = createdTimeEvent {
            createdEvent.editedEvent = nil
            timeEvents.append(createdTimeEvent)
            events.append(createdEvent)
            saveContext()
            self.createdEvent = nil
            self.createdTimeEvent = nil
            endEventEditing()
        }
        reloadData()
    }
    func getUpdatedContext()->NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    func saveContext(){
        let context = getUpdatedContext()
        
        do{
            try context.save()
        }catch{
            
            print(error.localizedDescription)
        }
        
    }

    func createTimeEvent(at date: Date, text: String, colorIndex: Int) -> EventEntity{
        let context = getUpdatedContext()
        let timeEventEntity = EventEntity.init(context: context)
        let endDate = date.addingTimeInterval(60*60)
        timeEventEntity.eventText = text
        timeEventEntity.startDate = date
        timeEventEntity.endDate = endDate
        timeEventEntity.colorlandex = Int64(colorIndex)
        
        return timeEventEntity
    }

    func getAllEvents() -> [EventEntity]{
        let context = getUpdatedContext()
        let itemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "EventEntity")
        
        do{
            let results = try context.fetch(itemRequest)
            
            let timeEvents = results as! [EventEntity]
            self.timeEvents = timeEvents
            return timeEvents
        }catch{
            print(error.localizedDescription)
            return []
        }
    }

}

