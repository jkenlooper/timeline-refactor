import { Component, OnInit } from '@angular/core';
import { Event } from '../event';
import { EventsService } from '../events.service';

@Component({
  selector: 'app-event-list',
  template: `
      <div>
        <app-new-event (reloadRequest)="setEvents($event)"></app-new-event>
        <ol>
          <li *ngFor="let event of events">
            <app-timeline-event [event]="event"></app-timeline-event>
          </li>
        </ol>
      </div>
  `,
  styleUrls: ['./event-list.component.css']
})
export class EventListComponent implements OnInit {
  events: Event[];

  constructor(private eventsService: EventsService) { }

  ngOnInit() {
    this.getEvents();
  }

  setEvents(events): void {
    console.log('setEvents', events);
    this.events = events.reverse();
  }

  getEvents(): void {
    this.eventsService.getEvents()
    .subscribe((events) => {
      this.setEvents(events);
    });
  }

}
