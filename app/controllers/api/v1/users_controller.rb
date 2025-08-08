class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :set_current_user, only: [:index, :create]

  def index
    users = User.order(:username)
    render json: {
      message: "Successfully retrieve list of users",
      users: serialize_collection(users, UserSerializer),
    }
  end

  def create
    validated_params = validate_with_contract(Users::CreateContract, params)
    user = User.new(validated_params[:user])
    
    if user.save
      render json: {
        message: "Successfully created user",
        user: serialize_object(user, UserSerializer),
      }, status: :created
    else
      render_error(user.errors.full_messages.join(', '))
    end
  end

  def show
    user = User.includes(:followers, :following).find(current_user.id)
    render json: {
      message: "Successfully retrieved user details",
      user: serialize_object(user, UserSerializer)
    }
  end

  def followers
    user = User.find(params[:id])
    followers = user.followers.includes(:sleep_records)
    render json: {
      message: "Successfully retrieved followers",
      followers: serialize_collection(followers, UserSerializer),
      count: followers.count
    }
  end
end
