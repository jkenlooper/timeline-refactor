import { Component, OnInit } from '@angular/core';
import { Event } from '../event';
import { EventsService } from '../events.service';

@Component({
  selector: 'app-event-list',
  template: `
        <ol>
          <li *ngFor="let event of events">
            <app-timeline-event [event]="event"></app-timeline-event>
          </li>
        </ol>
  `,
  styleUrls: ['./event-list.component.css']
})
export class EventListComponent implements OnInit {
  events: Event[];

  constructor(private eventsService: EventsService) { }

  ngOnInit() {
    this.getEvents();
  }

  getEvents(): void {
    this.eventsService.getEvents()
    .subscribe((events) => {
      this.events = events;
    });
  }

}
