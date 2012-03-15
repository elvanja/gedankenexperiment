=begin
  Pros:
  * business objects expose only persistence methods that are need for the rest of the application (see ConferenceRoom#find_by_room_number)
  * from business objects to persistence there is only one route, the doman class
  * persistence layer is only in one place, easily replaceable

  Cons:
  * business objects directly reference the persistence layer, no dependency injection (see ConferenceRoom#find_by_room_number)
  * persistence is not implemented but it is still used in business objects (see ConferenceRoom#book_me)
  * domain objects need to know how to (de)serialize themselves
=end

# domain / business rules
class ConferenceRoom
  include HashSerialization #implements new_from_hash and to_hash

  def self.find_by_room_number(number)
    new_from_hash ConferenceRoomRepository.find_by_room_number(number)
  end

  def book_me(from, to)
    @from, @to = from, to
    ConferenceRoomRepository.update(to_hash)
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
    implement_concrete_storage_retrieval(number)
  end

  def self.update(room)
    implement_concrete_storage_save(room)
  end
end

describe ConferenceRoom do
  it "books the room" do
    ConferenceRoomRepository.should_receive(update).with({from: '10AM', to: '11AM' })
    subject.book_me('10AM', '11AM')
  end
end
