class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :authenticate_user!

  # Send a user to the admins index after sending invitations
  def after_invite_path_for(inviter, invitee)
    users_path
  end
end
