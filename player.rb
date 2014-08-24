require 'delegate'

class Player

  def actions
    [
      WarriorSneakyRanger,
      WarriorRanger,
      WarriorReverse,
      WarriorRescue,
      #WarriorRescueBehind,
      WarriorRunToStairs,
      WarriorRecoupHealth,
      WarriorRetreat,
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
      warrior.being_attacked? &&
      warrior.feel.empty? &&
      warrior.look(:backward).any? {|space|
        space.enemy?
      }
    end
  end

  class WarriorRanger < WarriorAction
    def perform_actions!
      warrior.shoot!
    end

    def run?
      warrior.being_attacked? &&
      warrior.feel.empty? &&
      warrior.look.any? {|space|
        space.enemy?
      }
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

  class WarriorRescueBehind < WarriorAction
    def perform_actions!
      if warrior.feel(:backward).empty?
        warrior.walk!(:backward)
      elsif warrior.feel(:backward).captive? 
        warrior.rescue!(:backward)
        session.rescued!
      end
    end

    def run?
      !session.rescued?
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
end
