// https://coryrylan.com/blog/subscribing-to-multiple-observables-in-angular-components
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Observable } from 'rxjs';
import { Subscription } from 'rxjs';

import { ExampleService } from '../example.service';

@Component({
  selector: 'app-example',
  templateUrl: './example.component.html',
  styleUrls: ['./example.component.css']
})
export class ExampleComponent implements OnInit {
  show: Boolean = true;
  first$: Observable<string>;
  second$: Observable<string>;
  third$: Observable<number>;

  constructor(private exampleService: ExampleService) { }

  ngOnInit() {
    this.first$ = this.exampleService.getSingleValueObservable();

    this.second$ = this.exampleService.getDelayedValueObservable();

    this.third$ = this.exampleService.getMultiValueObservable();
  }
}
