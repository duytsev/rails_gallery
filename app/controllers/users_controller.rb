class UsersController < ApplicationController
  before_action :require_login, except: [:new, :create]
  before_action :admin_user?, only: [:index, :destroy]
  before_action :no_users_or_admin?, only: [:new, :create]
  before_action :valid_user, only: [:show, :reset_password]

  def index
    @users = User.paginate(page: params[:page]).order('id ASC')
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.admin = true if no_users?
    if @user.save
      session[:has_users?] = true
      flash[:success] = "User #{@user.login} successfully created"
      if !logged_in?
        auto_login @user
        flash[:success] = "Hello, #{@user.login}!"
      end
      redirect_to users_path
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    redirect_to users_path
  end

  def reset_password
    if invalid_old_password?(@user) || not_eql_new_passwords?
      flash[:danger] = 'Old password is invalid or/and new password are not equal'
    else
      new_crypted_password = encrypt(params[:new_password], @user.salt)
      if @user.update_attributes(crypted_password: new_crypted_password)
        flash[:success] = 'Password successfully updated'
      end
    end
    redirect_to @user
  end

  private

  def user_params
    params.require(:user).permit(:email, :login, :password, :password_confirmation)
  end

  def admin_user?
    if logged_in? && !current_user.admin
      redirect_to root_path
    end
  end

  def invalid_old_password?(user)
    !user.valid_password? params[:old_password]
  end

  def not_eql_new_passwords?
    !params[:new_password].eql?(params[:new_password_confirmation])
  end

  def no_users?
    !has_users?
  end

  def no_users_or_admin?
    if logged_in? && !current_user.admin
      redirect_to root_path
    elsif !logged_in? && has_users?
      redirect_to login_path
    end
  end

  def valid_user
    @user = User.find(params[:id])
    if current_user != @user && !current_user.admin
      redirect_to root_path
    end
  end
end
