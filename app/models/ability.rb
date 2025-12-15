class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    elsif user.manager?
      can :index, User
      can :show, User, role: "employee"
      can :show, User, id: user.id
      can :update, User, role: "employee"
      can :update, User, id: user.id
      can :create, User, role: [ "employee" ]
      can :read, :admin_graphic
    elsif user.employee?
      can :index, User
      can :show, User, id: user.id
      can :update, User, id: user.id
    end
  end
end
