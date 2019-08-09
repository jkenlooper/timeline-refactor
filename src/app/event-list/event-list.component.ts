import { Component, OnInit, Input } from '@angular/core';
import { Event } from '../event';

@Component({
  selector: 'app-event-list',
  template: `
    <ol>
      <li *ngFor="let event of filteredEvents">
        <app-timeline-event [event]="event"></app-timeline-event>
      </li>
    </ol>
  `,
  styleUrls: ['./event-list.component.css']
})
export class EventListComponent {

  filteredEvents: Event[];

  @Input()
  set events (list) {
    if (list && Array.isArray(list)) {
    this.filteredEvents = list.reverse();
    }
  }

  constructor() { }
}
