import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpResponse } from '@angular/common/http';
import { Event } from './event';
import { Observable, of } from 'rxjs';
import { catchError, map, mergeMap, tap } from 'rxjs/operators';

const httpOptions = {
  /*
  headers: new HttpHeaders({
    'Content-Type': 'application/json'
  }),
   */
  headers: {
    'Content-Type': 'application/json'
  },
  responseType: 'text'
};

@Injectable({
  providedIn: 'root'
})
export class EventsService {
  eventsUrl = '/api/events/';

  constructor(private http: HttpClient) { }

  getEvents(): Observable<Event[]> {
    return this.http.get<Event[]>(this.eventsUrl);
  }

  createEvent (event: Event): Observable<Event[]|string> {
    console.log('createEvent', event);
    return this.http.post(this.eventsUrl, event, { responseType: 'text' })
      .pipe(
        mergeMap((response) => {
          console.log('response?', response, event);
          return this.getEvents();
          // return response;
        }),
        catchError(this.handleError())
      );
  }
    /*
        msg = `Added event:  ${response.status} ${response.statusText}`
      }, function (err) {
        if (this.$window.location.host === 'timeline.weboftomorrow.com') {
          msg = 'Event Added.  Not saved to server.'
        } else {
          msg = `Event not saved to server: ${err.status} ${err.statusText}`
     */

  private handleError () {
    return (error: any) => {
      console.log('error?', error);

      return 'oops';
    };
  }

}
