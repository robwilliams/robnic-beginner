class WarriorSession
  def previous_health
    @previous_health ||= 0
  end

  def rescued!
    @rescued = true
  end

  def rescued?
    @rescued
  end

  def end_turn(warrior)
    self.previous_health = warrior.health
  end

  private
  def previous_health=(health)
    @previous_health = health
  end
end
