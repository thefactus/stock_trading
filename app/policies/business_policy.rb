# frozen_string_literal: true

class BusinessPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if user.buyer?
        scope.with_available_shares
      elsif user.owner?
        scope.where(owner_id: user.id)
      else
        scope.none
      end
    end
  end

  def index?
    user.buyer?
  end

  def owner_index?
    user.owner?
  end

  def view_purchases?
    user.buyer?
  end
end
