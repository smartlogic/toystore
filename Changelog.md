I will do my best to keep this up to date with significant changes here, starting in 0.8.3.

* 0.10.x => 0.11.0

  * Added get_multiple which returns Hash of id pointed at instance.
  * Aliased get_multi to get_multiple which means it now returns Hash instead of Array.
  * Updated to latest version of adapter.

* 0.10.4
  * Support for ActiveSupport/ActiveModel 3.2.*

* 0.10.3
  * More liberal uuid gem dependency version

* 0.10.2
  * [Allow changing list attribute type](https://github.com/jnunemaker/toystore/commit/a5b1a944622509c32688d2e56088a7d7aa6fc0b3)
  * [No longer include id in `persisted_attributes`](https://github.com/jnunemaker/toystore/commit/9f713311ebf174e314db700392e27af86ca00662)
  * [Allow overriding `persist` safely](https://github.com/jnunemaker/toystore/commit/304e50c7e4ac11a365ae00f5d4caed722de31909)
  * [Choose accessor over `write_attribute` for `attributes=`](https://github.com/jnunemaker/toystore/commit/65a8f81d933f0ebe1f13c9b1ff776f9e20333cb3)

* 0.10.0
  * [Reference proxy api changes](https://github.com/jnunemaker/toystore/pull/5) thanks to jakehow
  * [Support for inheritance](https://github.com/jnunemaker/toystore/pull/4)
  * [Pass model class to callable default](https://github.com/jnunemaker/toystore/commit/45eff74fb712e5b2a437e3c09b382421fc05539d)
  * [Added #hash](https://github.com/jnunemaker/toystore/commit/0769f548be669ad1b456cb1b8e11e394e0fee303)
  * [Added pretty inspect for classes](https://github.com/jnunemaker/toystore/commit/2fdc18b8d8428a932c1e5eeafa6a4db2269f1473)
  * [Always show id first in #inspect](https://github.com/jnunemaker/toystore/commit/145312b961a519ab84b010d37be075d85fa290a2)
  * [Moved object serialization into Toy::Object](https://github.com/jnunemaker/toystore/commit/d9431557f0f12c4e171fc888f3eb846fb631d4aa)

* 0.8.3 => 0.9.0
  * [Changed from `store` to `adapter`](https://github.com/jnunemaker/toystore/pull/1)
  * [Embedded objects were removed](https://github.com/jnunemaker/toystore/pull/2)
  * [Defaulted `adapter` to memory and removed `has_adapter?`](https://github.com/jnunemaker/toystore/commit/64268705fcb22d82eb7ac3e934508770ceb1f101)
  * [Introduced Toy::Object](https://github.com/jnunemaker/toystore/commit/f22fddff96b388db3bd22f36cc1cc29b28d0ae5e).
  * [Default Identity Map to off](https://github.com/jnunemaker/toystore/compare/02b652b4dbd4a652bf3d788fbf8cf7d0bae805f6...5cec60be60f9bf749964d5c2d437189287d6d837)
  * Removed several class methods related to identity map as well (identity_map_on/off/on?/off?/etc)
