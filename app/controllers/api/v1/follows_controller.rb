class Api::V1::FollowsController < Api::V1::BaseController
  def create
    validated_params = validate_with_contract(Follows::CreateContract, params, current_user: current_user)
    followed_user = User.find(validated_params[:followed_id])

    result = Follows::CreateService.call(current_user, followed_user)
    
    if result.success?
      render json: { 
        message: result.data[:message],
        following: serialize_object(result.data[:following], UserSerializer)
      }, status: :created
    else
      render_error(result.error)
    end
  end

  def destroy
    validated_params = validate_with_contract(Follows::DestroyContract, params, current_user: current_user)
    followed_user = User.find(validated_params[:id])

    result = Follows::DestroyService.call(current_user, followed_user)
    
    if result.success?
      render json: { 
        message: result.data[:message],
        unfollowed: serialize_object(result.data[:unfollowed], UserSerializer)
      }
    else
      render_error(result.error)
    end
  end

  def index
    per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
    following = current_user.following.order(:name).page(params[:page]).per(per_page)
    
    render json: {
      following: serialize_collection(following, UserSerializer),
      pagination: pagination_meta(following)
    }
  end

  def followers
    per_page = (params[:per_page] || 20).to_i.clamp(1, 100)
    followers = current_user.followers.order(:name).page(params[:page]).per(per_page)
    
    render json: {
      followers: serialize_collection(followers, UserSerializer),
      pagination: pagination_meta(followers)
    }
  end
end
