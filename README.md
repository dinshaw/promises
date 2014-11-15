# Promise
This is not production code (at the moment). It is a conceptual demo.
Slides for the accompanying presentation are here :  http://dinshaw.github.io/promises-sildes/#/6

For our context, 'resolve' chooses between 'fulfillment' (success) and 'rejection' (failure)

## Resolve:
Settle or find a solution to (a problem, dispute, or contentious matter).

Decide firmly on a course of action.

## Fulfill:
Bring to completion or reality; achieve or realize (something desired, promised, or predicted).


## Installation
Clone this repo.
Run `rake install`
Then in irb, you should be able to `require 'promise'`

## Similar projects:
- [promise.rb](https://github.com/lgierth/promise.rb/blob/master/README.md)
- [concurrent-ruby](https://github.com/jdantonio/concurrent-ruby), Promises/A(+) implementation, thread based
- [ruby-thread](https://github.com/meh/ruby-thread), thread/mutex/condition variable based, thread safe
- [promise](https://github.com/bhuga/promising-future), a.k.a. promising-future, classic promises and futures, thread based
- [celluloid-promise](https://github.com/cotag/celluloid-promise), inspired by Q, backed by a Celluloid actor
- [em-promise](https://github.com/cotag/em-promise), inspired by Q, backed by an EventMachine reactor
- [futuristic](https://github.com/seanlilmateus/futuristic), MacRuby bindings for Grand Central Dispatch
- [methodmissing/promise](https://github.com/methodmissing/promise), thread based, abandoned

## Contributing

1. Fork it ( https://github.com/[my-github-username]/promise/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
