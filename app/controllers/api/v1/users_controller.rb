class Api::V1::UsersController < Api::V1::BaseController
  skip_before_action :set_current_user, only: [:index, :create]

  def index
    validated_params = validate_with_contract(Users::IndexContract, params)
    
    per_page = (validated_params[:per_page] || 20).to_i.clamp(1, 100)
    users = User.all
    
    # Apply search filter
    if validated_params[:search].present?
      search_term = "%#{validated_params[:search]}%"
      users = users.where("name ILIKE ? OR username ILIKE ?", search_term, search_term)
    end
    
    users = users.order(:username).page(validated_params[:page]).per(per_page)
    
    render json: {
      message: "Successfully retrieve list of users",
      users: serialize_collection(users, UserSerializer),
      pagination: pagination_meta(users),
      search: validated_params[:search]
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
    per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
    followers = user.followers.includes(:sleep_records).order(:name).page(params[:page]).per(per_page)
    
    render json: {
      message: "Successfully retrieved followers",
      followers: serialize_collection(followers, UserSerializer),
      pagination: pagination_meta(followers)
    }
  end
end
