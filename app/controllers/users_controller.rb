# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, except: %i[import index]

  before_action :restrict_to_staff

  def deactivate
    @user.update! active: false
    flash[:notice] = 'User was deactivated successfully.'
    redirect_to users_url
  end

  def destroy
    if @user.destroy
      flash[:notice] = 'User was deleted successfully.'
    else
      flash[:alert] = 'Cannot delete drivers who have incidents in their name.'
    end
    redirect_to users_url
  end

  def import
    if request.post?
      xml = Nokogiri::XML params.require(:file).open
      statuses = User.import_from_xml(xml)
      if statuses
        message = "Imported #{statuses[:imported]} new users"
        unless statuses[:updated].zero?
          message += " and updated #{statuses[:updated]}"
        end
        message += '.'
        if statuses[:rejected].zero?
          redirect_to users_url, notice: message
        else
          message += " #{statuses[:rejected]} were rejected."
          redirect_to users_url, alert: message
        end
      else render :import, alert: 'Could not import from file.'
      end
    end
  end

  def incidents
    @incidents = @user.incidents.order :occurred_at
  end

  def index
    @inactive = params[:inactive] == 'true'
    @users = if @inactive
               User.inactive.name_order
             else User.active.name_order
             end
  end

  def reactivate
    @user.update! active: true
    flash[:notice] = 'User was reactivated successfully.'
    redirect_to users_url
  end

  def update
    @user.assign_attributes user_params
    attempt_save
  end

  private

  def attempt_save
    if @user.save
      flash[:notice] = "User was #{params[:action]}d successfully."
      redirect_to users_url
    else
      flash[:errors] = @user.errors.full_messages
      render 'edit'
    end
  end

  def find_user
    @user = User.find_by id: params.require(:id)
    render nothing: true, status: :not_found and return unless @user.present?
  end

  def user_params
    attrs = params.require(:user).permit :first_name, :last_name, :badge_number,
                                         :supervisor, :staff, :hastus_id,
                                         :division, :email
    if attrs[:password].blank?
      attrs.delete :password
      attrs.delete :password_confirmation
    end
    attrs
  end
end
