require 'pry'
class Player < ActiveRecord::Base
  validates :name, uniqueness: true

  def end_turn
    players = Player.all
    last_player = players.last
    if self == last_player
      next_player = players.first
    else
      next_player = players.find(self.id + 1)
    end
    self.update(turn: 'f')
    next_player.update(turn: 't')
  end

  def roll_dice
    roll = rand(6) + 1
    self.update({:dice_roll => roll})
    roll
  end

  # def move(new_coords)
  #   kitchen = ['A1', 'A2', 'B1', 'B2']
  #   hall = ['A5', 'A6', 'B5', 'B6']
  #   lounge = ['A9', 'A10', 'B9', 'B10']
  #   library = ['E1', 'E2', 'F1', 'F2']
  #   cellar = ['E5', 'E6', 'F5', 'F6']
  #   pool = ['E9', 'E10', 'F9', 'F10']
  #   laboratory = ['I1', 'I2', 'J1', 'J2']
  #   dining = ['I5', 'I6', 'J5', 'J6']
  #   study = ['I9', 'I10', 'J9', 'J10']
  #   rooms = kitchen + hall + lounge + library + cellar + pool + laboratory + dining + study
  #   guess_allowed = false ## this will be the return value?
  #   new_space = Space.where(coordinates: new_coords).first
  #   doors = Space.where('space_type LIKE ?', '%Door').all
  #   original_space = Space.find_by(player_id: self.id)
  #   original_coords = original_space.coordinates
  #   available_spaces = self.available_spaces(original_coords)
  #   roll = self.dice_roll
  #   ## available_spaces does include the doors, but it won't include new_space if new_space is a room
  #   binding.pry
  #   new_space_type = new_space.space_type ## expect a string 'Kitchen' or 'Kitchen Door'
  #   if new_space_type =! nil
  #
  #   if ((roll > 0) && (available_spaces.include?(new_space.coordinates))) || ## if roll > 0 && new_space is the specific room associated with that door
  #     ## rooms.include?(new_space.coordinates)) ## If new_space is in available_spaces, and new_space is included in room
  #     if (doors.include?(original_space)) && (rooms.include?(new_space.coordinates)) ## If they're on a door, and new_space is a room, then move them into the room (update new_space), change guess_allowed = true.
  #       new_space.update(player_id: self.id)
  #       original_space.update(player_id: nil)
  #       guess_allowed = true
  #       roll -= 1
  #       self.update(dice_roll: roll)
  #     else ## i.e. new_space is NOT a room
  #       new_space.update(player_id: self.id)
  #       original_space.update(player_id: nil)
  #       roll -= 1
  #       self.update(dice_roll: roll)
  #     end
  #   # else ## i.e. They have no rolls left or they didn't click an adjacent, available space
  #   end
  #   guess_allowed
  # end

  def move(new_coords)
    # Setup
    roll = self.dice_roll
    original_space = Space.find_by(player_id: self.id)
    original_coords = original_space.coordinates
    available_spaces = self.available_spaces(original_coords)
    new_space = Space.find_by(coordinates: new_coords)
    doors = Space.where('space_type LIKE ?', '%Door').all
    rooms_hash = {0 => 'Kitchen', 1 => 'Hall', 2 => 'Lounge', 3 => 'Library', 4 => 'Cellar', 5 => 'Pool Room', 6 => 'Laboratoy', 7 => 'Dining Room', 8 => 'Study'}
    kitchen = ['A1', 'A2', 'B1', 'B2']
    hall = ['A5', 'A6', 'B5', 'B6']
    lounge = ['A9', 'A10', 'B9', 'B10']
    library = ['E1', 'E2', 'F1', 'F2']
    cellar = ['E5', 'E6', 'F5', 'F6']
    pool = ['E9', 'E10', 'F9', 'F10']
    laboratory = ['I1', 'I2', 'J1', 'J2']
    dining = ['I5', 'I6', 'J5', 'J6']
    study = ['I9', 'I10', 'J9', 'J10']
    rooms = [kitchen, hall, lounge, library, cellar, pool, laboratory, dining, study]
    # If statements
    if roll > 0
      if available_spaces.include?(new_space.coordinates)
        if doors.include?(original_space)
          binding.pry
          door_string = original_space.space_type
          nearby_room = door_string.split(" Door")[0]
          room_index = rooms_hash.index(nearby_room)
          nearby_room_spaces = rooms[room_index]
          if nearby_room_spaces.include?(new_space)
            new_space.update(player_id: self.id)
            original_space.update(player_id: nil)
            guess_allowed = true
            roll -= 1
            self.update(dice_roll: roll)
          else # new_space is not in nearby_room
            new_space.update(player_id: self.id)
            original_space.update(player_id: nil)
            roll -= 1
            self.update(dice_roll: roll)
          end
        else # if current space is not a door
          new_space.update(player_id: self.id)
          original_space.update(player_id: nil)
          roll -= 1
          self.update(dice_roll: roll)
        end
      end
    end
  end


  # def available_spaces(current_coords) ## from the current player coords, get the spaces which are adjacent and open (blank space or blank door)
  #   letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
  #   numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
  #   player_x_axis = current_coords.split('', 2)[0]
  #   player_y_axis = current_coords.split('', 2)[1]
  #   available_spaces = []
  #   blanks = Space.where(space_type: 'space', player_id: nil)
  #   doors = Space.where('space_type LIKE ?', '%Door').all
  #   rooms_and_doors = Space.where.not(space_type: 'space').all
  #   rooms = rooms_and_doors - doors
  #   empty = Space.where(player_id: nil).all
  #   empty_doors = doors & empty
  #   open_spaces = blanks + empty_doors ## Should not add rooms
  #   open_spaces.each do |space|
  #     space_x_axis = space.coordinates.split('', 2)[0]
  #     space_y_axis = space.coordinates.split('', 2)[1]
  #     ## (if on the y axis it's 1 away, and the x-axis is the same) XOR vice versa
  #     if (((player_y_axis.to_i - space_y_axis.to_i).abs == 1) && (letters.index(player_x_axis) == letters.index(space_x_axis))) ^ (((letters.index(player_x_axis) - letters.index(space_x_axis)).abs == 1) && (player_y_axis.to_i == space_y_axis.to_i))
  #       available_spaces.push(space.coordinates)
  #     end
  #   end
  #   available_spaces
  # end

  def available_spaces(current_coords)
    ## Setup
    letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
    numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
    kitchen = ['A1', 'A2', 'B1', 'B2']
    hall = ['A5', 'A6', 'B5', 'B6']
    lounge = ['A9', 'A10', 'B9', 'B10']
    library = ['E1', 'E2', 'F1', 'F2']
    cellar = ['E5', 'E6', 'F5', 'F6']
    pool = ['E9', 'E10', 'F9', 'F10']
    laboratory = ['I1', 'I2', 'J1', 'J2']
    dining = ['I5', 'I6', 'J5', 'J6']
    study = ['I9', 'I10', 'J9', 'J10']
    rooms_hash = {0 => 'Kitchen', 1 => 'Hall', 2 => 'Lounge', 3 => 'Library', 4 => 'Cellar', 5 => 'Pool Room', 6 => 'Laboratoy', 7 => 'Dining Room', 8 => 'Study'}
    rooms = [kitchen, hall, lounge, library, cellar, pool, laboratory, dining, study]
    doors = Space.where('space_type LIKE ?', '%Door').all
    all_room_coords = kitchen + hall + lounge + library + cellar + pool + laboratory + dining + study
    all_room_spaces = []
    all_room_coords.each do |coords|
      room_space = Space.find_by(coordinates: coords)
      all_room_spaces.push(room_space)
    end
    empty_spaces = Space.where(player_id: nil).all
    empty_room_spaces = all_room_spaces & empty_spaces
    current_space = Space.find_by(coordinates: current_coords)
    player_x_axis = current_coords.split('', 2)[0]
    player_y_axis = current_coords.split('', 2)[1]
    available_spaces = []
    available_coords = []
    empty_halls = Space.where(space_type: 'space', player_id: nil)
    doors = Space.where('space_type LIKE ?', '%Door').all
    empty_doors = doors & empty_spaces
    empty_room_spaces = []
    rooms.each do |room|
      room.each do |room_coords|
        room_space = Space.find_by(coordinates: room_coords)
        if room_space.player_id == nil
          empty_room_spaces.push(room_space)
        end
      end
    end
    ## Check which type of space current_coords is with if statement
    if current_space.space_type == 'space'
      available_spaces = empty_halls + empty_doors
      available_spaces.each do |space|
        space_x_axis = space.coordinates.split('', 2)[0]
        space_y_axis = space.coordinates.split('', 2)[1]
        ## (if on the y axis it's 1 away, and the x-axis is the same) XOR vice versa
        if (((player_y_axis.to_i - space_y_axis.to_i).abs == 1) && (letters.index(player_x_axis) == letters.index(space_x_axis))) ^ (((letters.index(player_x_axis) - letters.index(space_x_axis)).abs == 1) && (player_y_axis.to_i == space_y_axis.to_i))
          available_coords.push(space.coordinates)
        end
      end
    elsif doors.include?(current_space) ## could dry up by not specifying which room. As long as the requirement is there for new_spaces to be one away, available_spaces only needs to be empty_halls + empty_rooms. Rooms don't need to take into account which room is nearby
      # nearby_room = current_space.space_type.split(" Door")[0]
      # room_index = rooms_hash.index(nearby_room)
      # nearby_room_spaces = rooms[room_index]
      # empty_nearby_room_spaces = nearby_room_spaces & empty_room_spaces
      available_spaces = empty_halls + empty_room_spaces
      available_spaces.each do |space|
        space_x_axis = space.coordinates.split('', 2)[0]
        space_y_axis = space.coordinates.split('', 2)[1]
        if (((player_y_axis.to_i - space_y_axis.to_i).abs == 1) && (letters.index(player_x_axis) == letters.index(space_x_axis))) ^ (((letters.index(player_x_axis) - letters.index(space_x_axis)).abs == 1) && (player_y_axis.to_i == space_y_axis.to_i))
          available_coords.push(space.coordinates)
        end
      end
    elsif all_room_spaces.include?(current_space) # Lastly, if you're on a room,
      available_spaces = empty_room_spaces + doors
      available_spaces.each do |space|
        space_x_axis = space.coordinates.split('', 2)[0]
        space_y_axis = space.coordinates.split('', 2)[1]
        if (((player_y_axis.to_i - space_y_axis.to_i).abs == 1) && (letters.index(player_x_axis) == letters.index(space_x_axis))) ^ (((letters.index(player_x_axis) - letters.index(space_x_axis)).abs == 1) && (player_y_axis.to_i == space_y_axis.to_i))
          available_coords.push(space.coordinates)
        end
      end
    end
    available_coords
  end

  def save_guess(cat, weapon, room)
    cat_id = cat.id
    weapon_id = weapon.id
    room_id = room.id
    Player.where(id: self.id).update({:guess => [cat_id, weapon_id, room_id] })
  end

  def player_guess_match(cat, weapon, room)
    player_guess = [cat, weapon, room]
    cards_to_pick_from = Card.where(answer: 'f').where.not(player_id: self.id)
    returned_card = nil
    player_guess.shuffle.each do |guess|
      if cards_to_pick_from.include?(guess)
        returned_card = guess
        break
      else
        returned_card = false
      end
    end
    returned_card
  end

  def self.place_player
    start_positions = ['H1', 'A3', 'D10', 'J7']
    index = 0
    Player.all.each do |player|
      Space.where(coordinates: start_positions[index]).update(:player_id => player.id)
      index += 1
    end
  end

end
