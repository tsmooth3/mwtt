class FamiliesController < ApplicationController
  def index
    @families = Family.all
    @user_families = current_user.families
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)
    
    if @family.save
      redirect_to @family, notice: 'Family created successfully!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @family = Family.find(params[:id])
    @is_member = current_user.families.include?(@family)
    @is_admin = current_user.family_admin?(@family)
  end

  private

  def family_params
    params.require(:family).permit(:name)
  end
end
