import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import {A11yModule} from '@angular/cdk/a11y';
import {FormsModule, ReactiveFormsModule} from '@angular/forms';
import {MatNativeDateModule} from '@angular/material/core';
import {MatInputModule} from '@angular/material/input';
import { HttpClientModule } from '@angular/common/http';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import {MatDatepickerModule} from '@angular/material/datepicker';

import { AppComponent } from './app.component';
import { EventListComponent } from './event-list/event-list.component';
import { TimelineEventComponent } from './timeline-event/timeline-event.component';
import { NewEventComponent } from './new-event/new-event.component';
import { ExampleComponent } from './example/example.component';

@NgModule({
  declarations: [
    AppComponent,
    EventListComponent,
    TimelineEventComponent,
    NewEventComponent,
    ExampleComponent
  ],
  imports: [
    BrowserModule,
    NoopAnimationsModule,
    FormsModule,
    ReactiveFormsModule,
    HttpClientModule,
    MatInputModule,
    MatNativeDateModule,
MatDatepickerModule,
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
