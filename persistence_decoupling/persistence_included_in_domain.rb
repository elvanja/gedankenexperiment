=begin
  Pros:
  * business objects get all the persistence methods "for free"
  * from business objects to persistence there is only one route
  * persistence layer is only in one place, easily replaceable
  * no (de)serialization needed

  Cons:
  * domain still needs to know about what persistence to use (see include)
  * this makes easy persistence swapping a problem
  * persistence methods used in other parts of the application are "somewhere else"
  * business objects sometimes do have to use persistence methods (see ConferenceRoom#book), seams like a code smell
=end

# domain / business rules
class ConferenceRoom
  include ConferenceRoomRepository

  def book_me(from, to)
    @from, @to = from, to
  end

  def self.book(room_number, from, to)
    room = find_by_room_number(room_number)
    room.book_me(from, to)
  end
end

# concrete persistence implementation
module ConferenceRoomRepository
  def self.included(klass)
    klass.class_eval do
      extend ClassMethods
    end
  end

  module ClassMethods
    def find_by_room_number(room_number)
      implement_concrete_storage_retrieval(number)
    end

    def update(room)
      implement_concrete_storage_save(room)
    end
  end
end

describe ConferenceRoom do
  context "domain" do
    it "shoud book room" do
      subject.book_me('10AM', '11AM')
      subject.from.should == '10AM'
    end

    it "should book room directly" do
      room = mock
      ConferenceRoom.should_receive(:find_by_room_number).and_return(room)
      room.should_receive(:book_me).with('10AM', '11AM')
      ConferenceRoom.book('HALL1', '10AM', '11AM')
    end
  end

  context "persistence" do
    it "should save booking" do
      subject.should_receive(:update)
      subject.book_me('10AM', '11AM')
    end
  end
end
