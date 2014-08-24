require 'delegate'

require 'warrior_session'
require 'warrior_action'

class Player

  def actions
    [
      WarriorSneakyCaptive,
      WarriorRetreat,
      WarriorSneakyRanger,
      WarriorRanger,
      WarriorReverse,
      WarriorRescue,
      WarriorRunToStairs,
      WarriorRecoupHealth,
      WarriorAttack,
      WarriorWalk,
    ]
  end

  def play_turn(warrior)
    warrior = AwesomeWarrior.new(warrior, session)

    actions.map {|action| 
      action.new(warrior, session) 
    }.select(&:run?).each {|action|
      return action.play_turn
    }
  end

  private
  def session
    @session ||= WarriorSession.new
  end
end

class WarriorSneakyCaptive < WarriorAction
  def perform_actions!
    warrior.pivot!
  end

  def run?
    warrior.look(:backward).any?(&:captive?)
  end
end

class WarriorReverse < WarriorAction
  def perform_actions!
    warrior.pivot!
  end

  def run?
    warrior.feel.wall?
  end
end

class WarriorSneakyRanger < WarriorAction
  def perform_actions!
    warrior.shoot!(:backward)
  end

  def run?
    warrior.feel.empty? &&
    warrior.look(:backward).any?(&:enemy?)
  end
end

class WarriorRanger < WarriorAction
  def perform_actions!
    warrior.shoot!
  end

  def run?
    warrior.feel.empty? &&
    warrior.look.any?(&:enemy?) &&
    warrior.look.none?(&:captive?)
  end
end

class WarriorRescue < WarriorAction
  def perform_actions!
    warrior.rescue!
  end

  def run?
    warrior.feel.captive?
  end
end

class WarriorRunToStairs < WarriorAction
  def perform_actions!
    warrior.walk!
  end

  def run?
    warrior.feel.stairs? && !warrior.feel.enemy?
  end
end

class WarriorRecoupHealth < WarriorAction
  def perform_actions!
    warrior.rest!
  end

  def run?
    !warrior.being_attacked? && warrior.health < 20
  end
end

class WarriorRetreat < WarriorAction
  def perform_actions!
    warrior.walk!(:backward)
  end

  def run?
    warrior.being_attacked? && warrior.health <= 10
  end
end

class WarriorAttack < WarriorAction
  def perform_actions!
    warrior.attack!
  end

  def run?
    warrior.feel.enemy?
  end
end

class WarriorWalk < WarriorAction
  def perform_actions!
    warrior.walk!
  end

  def run?
    true
  end
end

class AwesomeWarrior < SimpleDelegator
  attr_reader :session

  def initialize(warrior, session)
    @session = session
    super(warrior)
  end

  def being_attacked?
    health < session.previous_health 
  end
end
