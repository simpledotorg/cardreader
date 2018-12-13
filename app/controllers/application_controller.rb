class ApplicationController < ActionController::Base
  include Pundit

  protect_from_forgery with: :exception
  before_action :authenticate_user!, :set_sentry_context

  # Send a user to the admins index after sending invitations
  def after_invite_path_for(inviter, invitee)
    users_path
  end

  private

  def set_sentry_context
    Raven.user_context(
      id: current_user.id,
      email: current_user.email,
      role: current_user.role
    ) if user_signed_in?
  end
end
