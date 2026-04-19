class ProjectsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all.includes(:user, :properties)
    @total_projects = @projects.count
    @active_projects = @projects.where(status: 'active').count
  end

  def show
    @properties = @project.properties
    @total_properties = @properties.count
    @available_properties = @properties.where(status: :available).count
  end

  def new
    if user_signed_in?
      @project = current_user.projects.build
    else
      redirect_to new_user_session_path, alert: 'You need to sign in to create a project.'
    end
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to @project, notice: 'Project was successfully created.'
    else
      render :new
    end
  end

  def edit
    # @project is set by set_project before_action
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: 'Project was successfully destroyed.'
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description, :status, :start_date, :end_date, images: [], videos: [])
  end
end