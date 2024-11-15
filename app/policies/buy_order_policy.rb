# frozen_string_literal: true

class BuyOrderPolicy < ApplicationPolicy
  def create?
    user.buyer?
  end

  def index?
    user.owner?
  end

  def update?
    user.owner? && record.business.owner_id == user.id
  end
end
