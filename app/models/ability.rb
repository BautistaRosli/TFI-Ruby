class Ability
  include CanCan::Ability

  def initialize(user)
    if user.nil?
      can :read, :public
    elsif user.admin?
      can :manage, :all
    elsif user.manager?
      can :index, User
      can :show, User, role: "employee"
      can :show, User, id: user.id
      can :update, User, role: "employee"
      can :update, User, id: user.id
      can :create, User, role: [ "employee" ]
      can :analize, :admin_graphics_path
    elsif user.employee?
      can :index, User
      can :show, User, id: user.id
      can :update, User, id: user.id
    end
  end
end
