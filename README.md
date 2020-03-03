# Schedule

A `protocol` defining functionalities for a schedule.

## `Schedule` protocol
A schedule timetable might be represented as ordered instances of `DateInterval`, where each instance's `start` date represents an occurence of the schedule event in fixed in time, and each instance's `duration` represents the effective duration of the scheduled event.

The `Schedule` protocol defines its `Element` as `DateInterval`.
The functionalities defined in the protocol can be used to obtain the schedule timetable elements.

### `isEmpty` property
Signals wheter a `Schedule` concrete instance is either empty or not.

### `contains(_:)` method
Used to check wheter a `Schedule` concrete instance contains or not a given date. 
That is if the given date falls in the represented schedule timetable or not.

### `schedule(matching:direction)` method
This method optionally returns an `Element` of the `Schedule` by checking the given date against the `Schedule` contained elements using the given `CalendarCalculationMatchingDateDirection` criteria for the calculation.

#### `CalendarCalculationMatchingDateDirection` enum
This enum is used to establish a criteria in calendar calculations for a schedule element. 
It consists in three cases: 
* `.on`: the calendar calculation should be done by matching a given date. That is the returned `Schedule.Element` contains a given date.
* `.firstAfter`: the calendar calculation should be done by matching the first schedule element starting after a given date. That is the `Schedule.Element` start date has to be after a given date. 
* `.firstBefore`: the calendar calculation should be done by matching the first schedule element starting before a given date. That is the `Schedule.Element` end date has to be before a given date 

### `Schedule(in:queue:then:)` method
Used to calculate asynchronoulsy the schedule elements in a given date interval. The result will be delivered in the given closure, which will be optionally excetuted on the given queue when provided.
The delivered result is of type `Result<[Element], Error>`, hence it could be either an array of date interval instances representing the elements of the schedule in the given date interval, or an error in case something went wrong during the calculation.

### `generate(start:end:)` method
This method returns a Sequence of the schedule's elements starting from the given start date and optionally ending on the given end date. That is, when end date is not provided the sequence might be infinite in case the schedule timetable doesn't define an end date internally. For this very reason is **strongly** recommended to use `Schedule(in:queue:then:)` method rather then iterating on the sequence returned from this method. Moreover, it's best to use lazy higher order functions (map, filter, etc.) on this sequence knowning it could be infinite.
This method is provided as default implementation.

### `Schedule.Generator` type and `generator` property
`Schedule` protocol defines a functional type `(Date, CalendarCalculationMatchingDateDirection) -> DateInterval?` and maps its instance property `generator` of this type to its instance method `schedule(matching:direction)`. 
That is a "generator" of `Schedule.Element` is referred to a fucntion of type `(Date, CalendarCalculationMatchingDateDirection) -> DateInterval?`.

### `Schedule.ResultCompletion` type
A convenient typealias for the closure type used for the result delivery from an asynchronous calculation: `(Result<[Schedule.Element], Error>) -> Void`.

### `Schedule.AsyncGenerator` type and `asyncGenerator` property
`Schedule` protocol defines a functional type `(DateInterval, DispatchQueue?, Schedule.ResultCompletion) -> Void` and maps its instance property `asyncGenerator` of this type to its instance method  `Schedule(in:queue:then:)`. 
That is a "generator" of `Schedule.Element` working asynchronously is referred to a function of type  `(DateInterval, DispatchQueue?, Schedule.ResultCompletion) -> Void`.

## `AnySchedule` concrete `Schedule` type
A concrete `Schedule` type which can be used to hide details of an underlaying other concrete type.
Can be initialized either by boxing another concrete `Schedule` instance, or by providing a closure of type `Schedule.Generator`. 
In the latter case, the resulting `AnySchedule` will use a default implementation for the `Schedule(in:queue:then:)` method which sequentially iterates over the elements calculated via the provided `Schedule.Generator` for providing its result. This sequential work is executed on a background queue. 


