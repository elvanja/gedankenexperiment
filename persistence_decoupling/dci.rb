=begin
  Pros:
  * business objects reference the persistence layer, but through dependency injection (see ConferenceRoom#book_me)
  * persistence layer is only in one place, easily replaceable

  Cons:
  * domain objects in all levels need to access persistence, see ConferenceRoomBookingContext#book
  * would like to delegate find_by_room_number to persistence, but don't know how
  * persistence is not implemented but it is still used in business objects (see ConferenceRoomBookingContext#book_me)
=end

# domain / business object
class ConferenceRoom
  attr_reader :number, :from, :to, :data_provider

  def initialize(hash)
    @number ||= hash[:number]
    @from ||= hash[:from]
    @to ||= hash[:to]
    @data_provider ||= hash[:data_provider]
  end

  def book_me(from, to)
    @from, @to = from, to
    @data_provider.update(self)
  end
end

# domain / business context
class ConferenceRoomBookingContext
  def book(room_number, from, to)
    room = ConferenceRoomRepository.find_by_room_number(room_number)
    room.book_me(from, to)
  end
end

# abstract persistence
class ConferenceRoomRepository
  def self.find_by_room_number(number)
    #just a placeholder
  end

  def self.update(hash)
    #just a placeholder
  end
end

# concrete persistence implementation
ConferenceRoomRepository.clas_eval do
  def self.find_by_room_number(number)
    ConferenceRoom.new implement_concrete_storage_retrieval(number).merge({data_provider: self})
  end

  def self.update(room)
    implement_concrete_storage_save(room)
  end
end

describe ConferenceRoom do
  it "shoud book room" do
    data_provider = mock
    room = ConferenceRoom.new({data_provider: data_provider})
    data_provider.should_receive(:update).with(room)
    room.book_me('10AM', '11AM')
    room.from.should == '10AM'
  end
end

describe ConferenceRoomBookingContext do
  it "should book room directly" do
    room = mock
    ConferenceRoomRepository.should_receive(:find_by_room_number).and_return(room)
    room.should_receive(:book_me).with('10AM', '11AM')
    ConferenceRoomBooker.book('HALL1', '10AM', '11AM')
  end
end
