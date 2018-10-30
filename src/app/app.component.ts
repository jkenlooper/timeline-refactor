import { Component, OnInit } from '@angular/core';

import { EventsService } from './events.service';
import { Event } from './event';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = 'timeline';
  events: Event[];

  constructor(private eventsService: EventsService) { }

  ngOnInit() {
    this.getEvents();
  }

  getEvents(): void {
    this.eventsService.getEvents()
    .subscribe((events) => {
      console.log(events);
      this.events = events;
    });
  }

  setEvents(events): void {
    this.events = events;
  }

}
