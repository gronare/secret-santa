class WishlistItemsController < ApplicationController
  before_action :set_participant
  before_action :set_wishlist_item, only: :destroy

  def index
    @wishlist_items = @participant.wishlist_items.order(created_at: :desc)
    @wishlist_item = WishlistItem.new
  end

  def create
    @wishlist_item = @participant.wishlist_items.build(wishlist_item_params)

    if @wishlist_item.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to wishlist_items_path, notice: "Item added to wishlist!" }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("wishlist_form",
            partial: "wishlist_items/form",
            locals: { wishlist_item: @wishlist_item })
        }
        format.html { redirect_to wishlist_items_path, alert: "Failed to add item." }
      end
    end
  end

  def destroy
    @wishlist_item.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to wishlist_items_path, notice: "Item removed." }
    end
  end

  private

  def set_participant
    @participant = Current.participant
    redirect_to root_path, alert: "Please sign in first." unless @participant
  end

  def set_wishlist_item
    @wishlist_item = @participant.wishlist_items.find(params[:id])
  end

  def wishlist_item_params
    params.require(:wishlist_item).permit(:description, :url, :price)
  end
end
