class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      can :read, :public
    elsif user.admin?
      can :manage, :all
    elsif user.manager?
      can :read, :all
      can :update, User, role: [ :employee, :manager ]
    elsif user.employee?
      can :read, :internal
      can :update, User, id: user.id
    end
  end
end
