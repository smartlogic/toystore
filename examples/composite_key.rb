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

  key :composite, attributes: {
    bucket: String,
    track_id: SimpleUUID::UUID,
  }
end

track = Track.new(:id => {:bucket => '2012'})

pp track.id
# #<Toy::Types::Composite:0x007fbb5d5b5458
#  @accessors_module=#<Module:0x007fbb5d5b2d20>,
#  @attributes={:bucket=>String, :track_id=>SimpleUUID::UUID},
#  @source=
#   {:bucket=>"2012",
#    :track_id=>
#     <UUID#70221350939500 time: 2012-11-21 11:21:29 -0500, usecs: 10219 jitter: 15500354836540125076>}>

pp track.id.bucket
# => "2012"

pp track.id.track_id
# => <UUID#70221350939500 time: 2012-11-21 11:21:29 -0500, usecs: 10219 jitter: 15500354836540125076>
