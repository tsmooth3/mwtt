class FamilyMembershipsController < ApplicationController
  def create
    @family = Family.find(params[:family_id])
    
    if current_user.families.any?
      redirect_to @family, alert: 'You can only be a member of one family. Please leave your current family first.'
      return
    end
    
    unless current_user.families.include?(@family)
      FamilyMembership.create!(
        user: current_user,
        family: @family,
        is_admin: false
      )
      redirect_to @family, notice: 'Successfully joined family!'
    else
      redirect_to @family, alert: 'You are already a member of this family.'
    end
  end

  def destroy
    @family = Family.find(params[:family_id])
    membership = FamilyMembership.find_by(user: current_user, family: @family)
    
    if membership && !membership.is_admin
      membership.destroy
      redirect_to families_path, notice: 'Left family successfully.'
    else
      redirect_to @family, alert: 'Cannot leave family as admin.'
    end
  end
end
