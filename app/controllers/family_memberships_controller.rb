class FamilyMembershipsController < ApplicationController
  def create
    @family = Family.find(params[:family_id])
    
    if current_user.families.any?
      redirect_to @family, alert: 'You can only be a member of one family. Please leave your current family first.'
      return
    end
    
    unless current_user.families.include?(@family)
      # First person to join becomes admin
      is_first_member = @family.users.empty?
      
      FamilyMembership.create!(
        user: current_user,
        family: @family,
        is_admin: is_first_member
      )
      
      notice_message = is_first_member ? 
        'Successfully joined family! You are now the admin.' : 
        'Successfully joined family!'
      
      redirect_to @family, notice: notice_message
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
