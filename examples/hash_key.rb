require 'pp'
require 'rubygems'
require 'pathname'

root_path = Pathname(__FILE__).dirname.join('..').expand_path
lib_path  = root_path.join('lib')
$:.unshift(lib_path)

require 'toystore'

class Track
  include Toy::Store

  adapter :memory, {}

  key :hash, attributes: {
    bucket: String,
    track_id: SimpleUUID::UUID,
  }
end

track = Track.new(:bucket => '2012')

pp track.id
# => {:bucket=>"2012", :track_id=> <UUID#70194110090200 time: 2012-11-19 16:40:24 -0500, usecs: 149874 jitter: 11675517131681036675>

pp track.bucket # => "2012"
pp track.track_id # => <UUID#70194110090200 time: 2012-11-19 16:40:24 -0500, usecs: 149874 jitter: 11675517131681036675>

track.bucket = '2011'

pp track.id # => :bucket is now "2011"
pp track.id_changed? # => true
