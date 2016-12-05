class BidsController < ApplicationController
  before_action :authorize

  def create
    @bid = Bid.new(bid_params)
    @auction = Auction.find(@bid.auction_id)
    @bid.dealer = current_dealer
    render :bad_request if @bid.bid_amount == 0
    if @auction.bids.empty? &&
      @bid.bid_amount <= @auction.max_price &&
      @bid.save

      return_bid
    elsif @bid.bid_amount < @auction.bids.last.bid_amount && @bid.save
      return_bid
    end
  end

  def destroy
    @bid = Bid.find(params[:bid_id])
    @bid.destroy
    redirect_to user_auction_path(params[:user_id], params[:auction_id])
  end
  private

  def delete_link
    "<td><a data-confirm='Are you sure?' id='destroy' rel='nofollow' data-method='delete'
    href='http://localhost:3000/bids/2?auction_id=2&amp;bid_id=330&amp;user_id=2'><button
    class='top-cta-button btn-user-auc btn-delete' type='button'>Delete Bid</button></a></td>"
    end

    def bid_params
      params.require(:bid).permit(:bid_amount, :auction_id, :dealer_id, :user_id)
    end

    def return_bid
      ActionCable.server.broadcast 'bids',
      bid: @bid.bid_amount,
      dealer: @bid.dealer.dealer_name.capitalize,
      company: @bid.dealer.company_name.capitalize,
      email: @bid.dealer.email,
      delete: delete_link
      head :ok
    end
  end
