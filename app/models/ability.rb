class Ability
  include CanCan::Ability

  def initialize(user)
    # Si no hay usuario logueado, user será nil
    if user.nil?
      # Visitantes: solo acceso a la parte pública
      can :read, :public
    elsif user.admin?
      can :manage, :all
    elsif user.manager?
      can :read, :all
      can :update, User, role: :employee
    elsif user.employee?
      can :read, :internal
      can :update, User, id: user.id
    end
  end
end
