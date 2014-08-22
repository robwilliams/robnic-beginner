class Player
  def play_turn(warrior)

    if unhealthy?(warrior) && !safe_to_rest?(warrior)
      warrior.walk!(:backward)
      @previous_health = warrior.health
      return
    end

    if !rescued?
      handle_captive_behind(warrior)
    elsif warrior.feel.enemy?
      warrior.attack!
    elsif warrior.feel.captive?
      warrior.rescue!
    else
      if unhealthy_and_safe_to_rest?(warrior)
        warrior.rest!
      else
        warrior.walk!
      end
    end

    @previous_health = warrior.health
  end

  def unhealthy_and_safe_to_rest?(warrior)
    unhealthy?(warrior) && safe_to_rest?(warrior)
  end

  def unhealthy?(warrior)
    warrior.health < 6
  end

  def safe_to_rest?(warrior)
    @previous_health <= warrior.health
  end

  def handle_captive_behind(warrior)
    if warrior.feel(:backward).empty?
      # as long as we haven't already hit the wall
      warrior.walk!(:backward)
    elsif warrior.feel(:backward).captive? 
      warrior.rescue!(:backward)
      rescued!
    elsif warrior.feel(:backward).wall?
      warrior.walk!(:forward)
    end
  end

  def rescued?
    @rescued ||= false
  end

  def rescued!
    @rescued = true
  end
end
