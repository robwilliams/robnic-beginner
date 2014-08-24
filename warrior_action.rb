class WarriorAction < Struct.new(:warrior, :session)
  def play_turn
    puts self.class.name
    perform_actions!
    session.end_turn(warrior)
  end

  private
  def end_turn
    session.previous_health = warrior.health
  end
end
