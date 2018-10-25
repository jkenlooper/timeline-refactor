import { Component, OnInit, EventEmitter, Output } from '@angular/core';

import { Event } from '../event';
import { EventsService } from '../events.service';

@Component({
  selector: 'app-new-event',
  templateUrl: './new-event.component.html',
  styleUrls: ['./new-event.component.css']
})
export class NewEventComponent implements OnInit {

  @Output() reloadRequest = new EventEmitter<Event[]>();

  reload(events) {
    console.log('emit reloadRequest', events);
    this.reloadRequest.emit(events);
  }

  constructor(private eventsService: EventsService) { }

  ngOnInit() {
  }

  add(title: string, datetime: string): void {
    title = title.trim();
    datetime = datetime.trim();
    if (!title || !datetime) { return; }

    const newEvent = new Event(datetime, title);

    this.eventsService.createEvent(newEvent)
      .subscribe((events) => {
        console.log('created event?', events, newEvent);
        this.reload(events);
      });
  }

}
