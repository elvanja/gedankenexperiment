=begin
  Pros:
  * persistence implementation is glued to the domain object, domain needs not know about the details
  * business objects get all the persistence methods "for free"
  * from business objects to persistence there is only one route
  * persistence layer is only in one place, easily replaceable
  * no (de)serialization needed

  Cons:
  * persistence methods used in other parts of the application are "somewhere else"
  * business objects sometimes do have to use persistence methods (see ConferenceRoom#book), seams like a code smell
=end

# domain / business rules
class ConferenceRoom
  def book_me(from, to)
    @from, @to = from, to
  end

  def self.book(room_number, from, to)
    room = find_by_room_number(room_number)
    room.book_me(from, to)
  end
end

# concrete persistence implementation
ConferenceRoom.clas_eval do
  def self.find_by_room_number(number)
    implement_concrete_storage_retrieval(number)
  end

  def update(room)
    implement_concrete_storage_save(room)
  end

  def book_me(from, to)
    super
    update
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
