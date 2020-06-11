class AutobotController < ApplicationController
  # include ApplicationHelper

  menu_item :settings
  before_action :find_project, :authorize

  helper :custom_fields
  helper :projects
  helper :autobot

  def edit
    @autobot = @project.autobot || Autobot.new(:project => @project)

    params[:autobot][:statuses] = [] if params[:autobot][:statuses].nil?
    params[:autobot][:trackers] = [] if params[:autobot][:trackers].nil?

    @autobot.safe_attributes= params[:autobot]
    @autobot.save if request.post?

    flash[:notice] = 'Autobot saved.' if @autobot.valid?
    flash[:error] = "#{error_messages_for(@autobot)}" if !@autobot.valid?

    redirect_to settings_project_path(@project, :tab => 'autobot')
  end

  private

  # Copied from ApplicationHelper because i don't know how to do it otherwise
  def error_messages_for(*objects)
    objects = objects.map {|o| o.is_a?(String) ? instance_variable_get("@#{o}") : o}.compact
    errors = objects.map {|o| o.errors.full_messages}.flatten
    render_error_messages(errors)
  end

  def render_error_messages(errors)
    html = ""
    if errors.present?
      html << "<ul>\n"
      errors.each do |error|
        html << "<li>#{error}</li>\n"
      end
      html << "</ul>\n"
    end
    html.html_safe
  end
  # Copied from ApplicationHelper because i don't know how to do it otherwise
  
end  