# Schedule

A `protocol` defining functionalities for a schedule.

## Introduction
A schedule timetable might be represented as ordered instances of `DateInterval`, where each instance's `start` date represents an occurence of the schedule event in fixed in time, and each instance's `duration` represents the effective duration of the scheudled event.

### `Schedule` protocol
The `Schedule` protocol defines its `Element` as `DateInterval`.
The functionalities defined in the protocol can be used to obtain the schedule timetable elements.

#### `isEmpty` property
Signals wheter a `Schedule` concrete instance is either empty or not.

#### `contains(_:)` method
Used to check wheter a `Schedule` concrete instance contains or not a given date. 
That is if the given date falls in the represented schedule timetable or not.

#### `schedule(matching:direction)` method
This method optionally returns an `Element` of the `Schedule` by checking the given date against the `Schedule` contained elements using the given `CalendarCalculationMatchingDateDirection` criteria for the calculation.

##### `CalendarCalculationMatchingDateDirection` enum
This enum is used to establish a criteria in calendar calculations for a schedule element. 
It consists in three cases: 
* `.on`: the calendar calculation should be done by matching a given date. That is the returned `Schedule.Element` contains a given date.
* `.firstAfter`: the calendar calculation should be done by matching the first schedule element starting after a given date. That is the `Schedule.Element` start date has to be after a given date. 
* `.firstBefore`: the calendar calculation should be done by matching the first schedule element starting before a given date. That is the `Schedule.Element` end date has to be before a given date 

### `Schedule(in:queue:then:)` method
Used to calculate asynchronoulsy the schedule elements in a given date interval. The result will be delivered in the given closure, which will be optionally excetuted on the given queue when provided.

